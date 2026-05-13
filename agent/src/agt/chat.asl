/* =========================================================
   STATE
   ========================================================= */

llm_available(true).


/* =========================================================
   CONNECTION
   ========================================================= */

+!connect_chat <-
    connect("127.0.0.1", 5000).

+connected <-
    .print("[CHAT] Connected").

+connection_failed <-
    .print("[CHAT] Connection failed").

-!connect_chat <-
    .print("[CHAT] Unable to connect — continuing offline").



/* =========================================================
   LLM STATE
   ========================================================= */

+llm_available(true) <-
    .print("[LLM] Available");
    !flush_queue.

+llm_available(false) <-
    .print("[LLM] Busy / unavailable").

+llm_done <-
    -llm_available(false);
    +llm_available(true);

    .print("[LLM] Available again");

    !flush_queue.

/* =========================================================
   MESSAGE INPUT
   ========================================================= */

+new_text(Msg) <-
    .print("[CHAT] Received: ", Msg);
    !enqueue(Msg);
    !flush_queue.



/* =========================================================
   QUEUE MANAGEMENT
   ========================================================= */

+!enqueue(Msg) <-
    +msg_queue(Msg);
    !print_queue_size.


+!print_queue_size <-
    .findall(M, msg_queue(M), All);
    .length(All, Size);
    .print("[QUEUE] Size: ", Size).


+!flush_queue
    : llm_available(false)
    <- .print("[QUEUE] Waiting for LLM").


+!flush_queue
    : not msg_queue(_)
    <- .print("[QUEUE] Empty").


+!flush_queue
    : llm_available(true) & msg_queue(_)
    <-
        -llm_available(true);
        +llm_available(false);

        !drain_queue(Messages);
        !dispatch(Messages).

/* =========================================================
   QUEUE DRAINING
   ========================================================= */

+!drain_queue(Messages) <-
    .findall(Msg, msg_queue(Msg), Messages);
    .abolish(msg_queue(_)).



/* =========================================================
   DISPATCH
   ========================================================= */

+!dispatch([]) <-
    .print("[LLM] Nothing to send").


+!dispatch(Messages) <-
    !join(Messages, Batch);
    !build_context(Context);

    .print("[LLM] Dispatching batch");
    .print("[LLM] Payload: ", Batch);

    promptLLM(Batch, Context).



/* =========================================================
   MESSAGE JOINING
   ========================================================= */

+!join([], "").

+!join([H], H).

+!join([H|T], Result) <-
    !join(T, TailText);
    .concat(H, " | ", Tmp);
    .concat(Tmp, TailText, Result).



/* =========================================================
   CONTEXT BUILDING
   ========================================================= */

+!build_context(Context) <-
    !memory_to_text(short, Short);
    !memory_to_text(semantic, Semantic);
    !memory_to_text(episodic, Episodic);

    !section("SHORT_TERM_MEMORY", Short, S1);
    !section("SEMANTIC_MEMORY", Semantic, S2);
    !section("EPISODIC_MEMORY", Episodic, S3);

    .concat(S1, S2, Tmp);
    .concat(Tmp, S3, Context).



+!section(Name, Content, Result) <-
    .concat("\n\n[", Name, Tmp1);
    .concat(Tmp1, "]\n", Tmp2);
    .concat(Tmp2, Content, Result).