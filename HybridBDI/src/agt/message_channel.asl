+!connect_chat <-
    connect("127.0.0.1", 5000).

+connected <-
    .print("[CHAT] Connected").

+connection_failed <-
    .print("[CHAT] Connection failed").

-!connect_chat <-
    .print("[CHAT] Unable to connect — continuing offline").

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


+!drain_queue(Messages) <-
    .findall(Msg, msg_queue(Msg), Messages);
    .abolish(msg_queue(_)).



+!dispatch([]) <-
    .print("Nothing to send").


+!dispatch(Messages) <-
    !join(Messages, Batch);
    !build_context(Context);

    .print("Dispatching batch");
    .print("Payload: ", Batch);

    translateUserMessage(Batch, Context).



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
    !memory_to_text(procedural, Procedural);
    !memory_to_text(semantic, Semantic);
    !memory_to_text(episodic, Episodic);


    !section("PROCEDURAL_MEMORY", Procedural, S1);
    !section("SHORT_TERM_MEMORY", Short, S2);
    !section("SEMANTIC_MEMORY", Semantic, S3);
    !section("EPISODIC_MEMORY", Episodic, S4);

    .concat(S1, S2, Tmp);
    .concat(Tmp, S3, Tmp1);
    .concat(Tmp1, S4, Context).

+!section(Name, Content, Result) <-
    .concat("\n\n[", Name, Tmp1);
    .concat(Tmp1, "]\n", Tmp2);
    .concat(Tmp2, Content, Result).