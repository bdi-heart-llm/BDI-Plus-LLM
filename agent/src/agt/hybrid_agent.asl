!start.

+!start <-
    .print("Booting up...");
    makeArtifact("roomSim", "wot.ThingArtifact",
        ["https://raw.githubusercontent.com/Interactions-HSG/example-tds/refs/heads/was/tds/interactions-lab.ttl"],
        SimId);
    focus(SimId);
    makeArtifact("lab", "lab.Lab", [], LabID);
    focus(LabID);
    linkArtifacts(LabID, "lab-td", SimId);
    makeArtifact("chatArt", "chat.ChatArtifact", [], ChatId);
    focus(ChatId);
    !connect_chat;
    makeArtifact("llmEngine", "llm.LlmEngine", [], LlmId);
    focus(LlmId);
    +linked(LabID).

+linked(LabID) : true <-
    .print("Linking complete → start sensing");
    !perceiveLab.

+!perceiveLab <-
    sense;
    .wait(1000);
    .print("ses");
    +should_be("OFF", "Z1Light");
    !perceiveLab.

+status(K, V) <-
    !add_short_term(K, V).

action_name("Z1Light",  "Control Lights Z1").
action_name("Z2Light",  "Control Lights Z2").
action_name("Z1Blinds", "Control Blinds Z1").
action_name("Z2Blinds", "Control Blinds Z2").

+!turn_on(Element) : action_name(Element, Action) <-
    .print("[ACTION] ON  -> ", Element);
    invokeAction(Action, [Element], [true]);
    sense.

+!turn_off(Element) : action_name(Element, Action) <-
    .print("[ACTION] OFF -> ", Element);
    invokeAction(Action, [Element], [false]);
    sense.

+should_be("ON", Element): status(Element, false) <-
    .print("OK! ", Element, " should be on.");
    !turn_on(Element).

+should_be("ON", Element): status(Element, true) <-
    .print("It was already ON").

+should_be("OFF", Element): status(Element, true) <-
    .print("OK! ", Element, " should be off.");
    !turn_off(Element).

+should_be("OFF", Element): status(Element, false) <-
    .print("It was already OFF").

{ include("chat.asl") }
{ include("short_memory.asl") }
{ include("semantic_memory.asl") }
{ include("episodic_memory.asl") }
{ include("memory_helpers.asl") }