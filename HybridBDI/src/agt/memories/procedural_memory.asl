valid_value(boolean, true).
valid_value(boolean, false).
valid_value(number,  V) :- number(V).
valid_value(string,  V) :- string(V).


memory_item("execute_action_on_element", ["Z1Light", "Control Lights Z1", boolean]) [memory(procedural), description("Turns the lights on or off in Zone 1")].
memory_item("execute_action_on_element", ["Z2Light","Control Lights Z2", boolean]) [memory(procedural), description("Turns the lights on or off in Zone 2")].
memory_item("execute_action_on_element", ["Z1Blinds", "Control Blinds Z1", boolean]) [memory(procedural), description("Opens or closes the window blinds in Zone 1")].
memory_item("execute_action_on_element", ["Z2Blinds", "Control Blinds Z2", boolean]) [memory(procedural), description("Opens or closes the window blinds in Zone 2")].

+!execute_action_on_element(Element, Action, NewValue)
    :  memory_item("execute_action_on_element", [Element, Action, Type]) & valid_value(Type, NewValue)
    <- .print("[", Action, "] ", Element, " -> ", NewValue, " (type: ", Type, ")");
       invokeAction(Action, [Element], [NewValue]);
       sense.

+!execute_action_on_element(Element, Action, NewValue)
    :  memory_item("execute_action_on_element", [Element, Action, Type]) & not valid_value(Type, NewValue)
    <- .print("[ERROR] Type mismatch for action '", Action,
              "': expected ", Type, ", got ", NewValue).

+!execute_action_on_element(_, Action, _)
    :  not memory_item(execute_action_on_element, [_, Action, _])
    <- .print("[ERROR] Unknown action: '", Action, "'").