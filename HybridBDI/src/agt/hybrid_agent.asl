!start.

+!start <-
    .print("Booting up...");
    !discover("labEnv", LabEnvId);
    !discover("labSensor", LabSensorId);
    focus(LabEnvId);
    focus(LabSensorId);
    linkArtifacts(LabSensorId, "lab-td", LabEnvId);
    !discover("userMessageChannel", UserMessageChannelId);
    focus(UserMessageChannelId);
    !connect_chat;
    !discover("clientLLM", ClientLLMId);
    focus(ClientLLMId);
    llmHealthCheck;
    +linked(LabSensorId).

+!discover(ArtName, Id)
    <- lookupArtifact(ArtName,Id).

-!discover(ArtName, Id)
    <- .wait(100);
    !discover(ArtName, Id).

+linked(LabSensorId) : true <-
    .print("Linking complete, start sensing");
    !perceiveLab.

+parse_response(achieve(Action))
    <-
    .print(Action);
    !!Action.

+parse_response(achieve(Action))  <- !!Action.
+parse_response(tell(Belief))     <- +Belief.
+parse_response(untell(Belief))   <- -Belief.
+parse_response(msg_fail(Reason)) <- .log(warning, Reason).

{ include("message_channel.asl") }
{ include("llm_state.asl") }
{ include("sense_lab.asl") }
{ include("memories/memory_helpers.asl") }
{ include("memories/working_memory.asl") }
{ include("memories/semantic_memory.asl") }
{ include("memories/episodic_memory.asl") }
{ include("memories/procedural_memory.asl") }

{ include("$jacamo/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }

