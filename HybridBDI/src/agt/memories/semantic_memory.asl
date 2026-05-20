memory_item(zones, "There are zone one and zone two in the lab") [memory(semantic)].
memory_item(zone_one, "Zone one has Z1Light and Z1Blinds") [memory(semantic)].
memory_item(zone_two, "Zone one has Z2Light and Z2Blinds") [memory(semantic)].

+!add_semantic_term(Key, Value)
    <- !add_memory(semantic, Key, Value).

+!semantic_to_text(Result)
    <- !memory_to_text(semantic, Result).