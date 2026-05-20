package llm;

import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;

public interface ClientLLM {
    @OPERATION
    public void llmHealthCheck();

    @OPERATION
    public void translateUserMessage(String msg, String agentKnowledgeContext);

    @INTERNAL_OPERATION
    void processTranslationAsync(String msg, String agentKnowledgeContext);
}
