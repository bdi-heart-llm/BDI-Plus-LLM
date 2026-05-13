+!add_short_term(Key, Value)
    <- !add_memory(short, Key, Value).

+!short_to_text(Result)
    <- !memory_to_text(short, Result).

+!print_short_term_memory
    <- !print_memory(short).