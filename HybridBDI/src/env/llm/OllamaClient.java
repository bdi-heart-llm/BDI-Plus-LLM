package llm;

import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class OllamaClient extends Artifact implements ClientLLM {

    private static final String OLLAMA_BASE_URL = "http://localhost:11434/api";
    private static final String OLLAMA = OLLAMA_BASE_URL+"/chat";

    private String model;

    private final HttpClient http = HttpClient.newHttpClient();
    private final Gson gson = new Gson();

    private final String SYSTEM_PROMPT = """
                You are the natural language interface of a BDI (Belief-Desire-Intention) agent.
                
                ## YOUR TASK
                Translate the user's natural language input into a JSON array of objects for the BDI agent.
                You must output ONLY a raw JSON array — no explanation, no markdown, no code fences, no preamble.
                
                Each object has a "functor" and "params":
                
                1. **Goal delegation** — when the user wants the agent to perform an action:
                {
                  "functor": "achieve",
                  "params": {
                    "action": "action name",
                    "args": [list of args]
                  }
                }
                
                2. **Belief revision** — when the user provides new information:
                - Add/update: { "functor": "tell",   "params": ["Key", value] }
                - Retract:    { "functor": "untell", "params": ["Key", value] }
                
                3. **Failure** — when the request cannot be mapped or would change nothing:
                { "functor": "msg_fail", "params": ["reason"] }
                
                ## RULES
                - Return ONLY a raw JSON array of objects.
                - Never invent ElementIDs or ActionNames not listed in PROCEDURAL_MEMORY.
                - Never emit achieve if the SHORT_TERM_MEMORY already has the target value.
                - Do not include any text outside the JSON array.
                """;

    public void init(String model) {
        this.model = model;
    }

    public void init() {
        this.model = "gpt-oss:120b-cloud";
    }

    @OPERATION
    public void llmHealthCheck() {
        execInternalOp("pingOllama");
    }

    @OPERATION
    public void translateUserMessage(String msg, String agentKnowledgeContext) {
        log("user input: " + msg);
        log("agentKnowledgeContext: " + agentKnowledgeContext);
        execInternalOp("processTranslationAsync", msg, agentKnowledgeContext);
    }

    @INTERNAL_OPERATION
    void pingOllama() {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(OLLAMA_BASE_URL+"/tags"))
                    .GET()
                    .timeout(java.time.Duration.ofSeconds(3))
                    .build();

            HttpResponse<String> response = http.send(request, HttpResponse.BodyHandlers.ofString());


            boolean available = response.statusCode() == 200;

            if (hasObsProperty("llm_available")) {
                getObsProperty("llm_available").updateValue(available);
            } else {
                defineObsProperty("llm_available", available);
            }
        } catch (Exception e) {
            getObsProperty("llm_available").updateValue(false);
        }
    }

    @INTERNAL_OPERATION
    public void processTranslationAsync(String msg, String agentKnowledgeContext) {

        try {
            String payload = buildOllamaPayload(msg, agentKnowledgeContext);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(OLLAMA))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(payload))
                    .build();

            HttpResponse<String> response = http.send(request, HttpResponse.BodyHandlers.ofString());

            JsonObject json = gson.fromJson(response.body(), JsonObject.class);
            String content = json.getAsJsonObject("message").get("content").getAsString();

            log("LLM raw response: " + content);

            try {
                JsonElement parsed = gson.fromJson(content, JsonElement.class);

                if (!parsed.isJsonArray()) {
                    failed("Unexpected response format: " + content);
                    return;
                }

                JsonArray items = parsed.getAsJsonArray();

                for (JsonElement el : items) {
                    JsonObject obj     = el.getAsJsonObject();
                    String     functor = obj.get("functor").getAsString();
                    String     inner   = buildTermFromJson(obj);

                    Literal literal = ASSyntax.parseLiteral(functor + "(" + inner + ")");
                    signal("parse_response", literal);
                }
            } catch (Exception e) {
                failed("Ollama error: " + e.getMessage());
            }

            signal("llm_done");
        } catch (Exception e) {
            failed("Ollama error: " + e.getMessage());
        }
    }


    private String buildOllamaPayload(String userInput, String agentKnowledgeContext) {
        JsonObject body = new JsonObject();
        body.addProperty("model", this.model); // Assuming 'this.model' is initialized during artifact init()
        body.addProperty("stream", false);
        body.addProperty("think", false);

        JsonArray messages = new JsonArray();

        JsonObject sysMsg = new JsonObject();
        sysMsg.addProperty("role", "system");
        sysMsg.addProperty("content", SYSTEM_PROMPT + "\n## AGENT KNOWLEDGE\n" + agentKnowledgeContext);

        JsonObject userMsg = new JsonObject();
        userMsg.addProperty("role", "user");
        userMsg.addProperty("content", "Task: " + userInput);

        messages.add(sysMsg);
        messages.add(userMsg);
        body.add("messages", messages);

        return gson.toJson(body);
    }

    private String buildTermFromJson(JsonObject obj) {
        String functor = obj.get("functor").getAsString();
        JsonElement params = obj.get("params");

        switch (functor) {
            case "achieve": {
                JsonObject p     = params.getAsJsonObject();
                String innerName = p.get("action").getAsString();
                JsonArray args   = p.get("args").getAsJsonArray();
                return innerName + "(" + joinArgs(args) + ")";
            }
            case "tell":
            case "untell": {
                JsonArray args = params.getAsJsonArray();
                return "status(" + joinArgs(args) + ")";
            }
            case "msg_fail": {
                JsonArray args = params.getAsJsonArray();
                return joinArgs(args);
            }
            default:
                return "";
        }
    }

    private String joinArgs(JsonArray args) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < args.size(); i++) {
            if (i > 0) sb.append(",");
            JsonElement arg = args.get(i);
            if (arg.isJsonPrimitive()) {
                var prim = arg.getAsJsonPrimitive();
                if (prim.isBoolean() || prim.isNumber()) {
                    sb.append(prim.getAsString());
                } else {
                    sb.append("\"").append(prim.getAsString()).append("\"");
                }
            }
        }
        return sb.toString();
    }
}
