memory_item(
    "Is dark",
    "The user said the lab was dark, according to beliefs, both lights were off. I did [{action: should_be, state: ON, element: Z2Light}, {action: should_be, state: ON, element: Z1Light}]"
    )[memory(episodic)].

+!add_episodic_term(Key, Value)
    <- !add_memory(episodic, Key, Value).

+!episodic_to_text(Result)
    <- !memory_to_text(episodic, Result).