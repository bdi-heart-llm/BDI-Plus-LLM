memory_item(
    "It's dark in zone 1",
    "User described an undesired state. Working memory: Z1Light=false, Z1Blinds=false. Both can contribute to fixing the condition. Output: [{\"functor\":\"achieve\",\"params\":{\"action\":\"execute_action_on_element\",\"args\":[\"Z1Light\",\"Control Lights Z1\",true]}},{\"functor\":\"achieve\",\"params\":{\"action\":\"execute_action_on_element\",\"args\":[\"Z1Blinds\",\"Control Blinds Z1\",true]}}]"
)[memory(episodic)].

memory_item(
    "Zone 1 has been dark all morning",
    "User made a past-tense observation. No procedural action triggered. Added new belief about room condition. Output: [{\"functor\":\"tell\",\"params\":[\"Z1\",\"dark\"]}]"
)[memory(episodic)].

memory_item(
    "Why is zone 1 so dark?",
    "User asked an explicit question. No action delegated, no belief revised. Output: [{\"functor\":\"msg_fail\",\"params\":[\"Wht is the reason zone 1 so currently dark?.\"]}]"
)[memory(episodic)].

+!add_episodic_term(Key, Value)
    <- !add_memory(episodic, Key, Value).

+!episodic_to_text(Result)
    <- !memory_to_text(episodic, Result).