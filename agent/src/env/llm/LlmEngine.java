package llm;

import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class LlmEngine extends Artifact {

    private static final String OLLAMA  = "http://localhost:11434/api/chat";
    private final String model = "gpt-oss:120b-cloud";

    private final HttpClient http = HttpClient.newHttpClient();
    private final Gson gson = new Gson();

    private String prompt;

    public void init(Object[] args) {

    }

    @OPERATION
    public void promptLLM(String task, String status){
        execInternalOp("chat", status, task);
    }


    @INTERNAL_OPERATION
    void chat(String status, String observation) {
        String baseTemplate = """
            You are a goal translator for a Jason BDI agent.
            
            ## YOUR TASK
            Convert a natural language user request into a structured JSON action the BDI agent can execute.
            
            ## AVAILABLE ACTIONS
            The agent can control named elements with two states: "ON" or "OFF".
            It uses the belief: should_be("ON" | "OFF", ElementName)
            
            ## OUTPUT FORMAT
            Always respond with ONLY valid JSON — no prose, no markdown, no explanation.
            
            ## RULES
            - Use ONLY element names from KNOWN ELEMENTS. Never invent names.
            - If the request is unrelated to controlling elements or unclear, use the respond action.
            - State must be exactly "ON" or "OFF".
            """;
        try {
            JsonObject body = new JsonObject();
            body.addProperty("model", this.model);

            body.addProperty("stream", false);
            body.addProperty("think", false);

            JsonArray messages = new JsonArray();
            JsonObject sysMsg = new JsonObject();
            sysMsg.addProperty("role", "system");
            sysMsg.addProperty("content", baseTemplate+status);

            JsonObject msg = new JsonObject();
            msg.addProperty("role", "user");
            msg.addProperty("content", "Task:" + observation);
            messages.add(sysMsg);
            messages.add(msg);

            body.add("messages", messages);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(OLLAMA))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(gson.toJson(body)))
                    .build();

            HttpResponse<String> response = http.send(request, HttpResponse.BodyHandlers.ofString());

            JsonObject json    = gson.fromJson(response.body(), JsonObject.class);
            String    content  = json.getAsJsonObject("message").get("content").getAsString();

            log("LLM raw response: " + content);

            JsonElement parsed = gson.fromJson(content, JsonElement.class);

            if (parsed.isJsonArray()) {

                JsonArray actions = parsed.getAsJsonArray();

                for (JsonElement el : actions) {

                    JsonObject obj = el.getAsJsonObject();

                    String action  = obj.get("action").getAsString();
                    String state   = obj.get("state").getAsString();
                    String element = obj.get("element").getAsString();

                    if (action.equals("should_be")) {
                        signal("should_be", state, element);
                    }
                }

            } else if (parsed.isJsonObject()) {

                JsonObject obj = parsed.getAsJsonObject();

                String action  = obj.get("action").getAsString();
                String state   = obj.get("state").getAsString();
                String element = obj.get("element").getAsString();

                if (action.equals("should_be")) {
                    signal("should_be", state, element);
                }
            }

            signal("llm_done");
        } catch (Exception e) {
            failed("Ollama error: " + e.getMessage());
        }
    }
}