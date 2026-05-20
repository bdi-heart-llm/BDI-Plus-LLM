+llm_available(true)  <-
    .print("[LLM] LLM is up and ready.");
    !flush_queue.
+llm_available(false) <- .print("[LLM] LLM is busy / not available.").

+llm_done <-
    -llm_available(false);
    +llm_available(true);
    .print("[LLM] Available again");
    !flush_queue.