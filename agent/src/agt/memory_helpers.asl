+!add_memory(Type, Key, Value)
    <- +memory_item(Key, Value)[memory(Type)].


+!memory_to_text(Type, Result)
    <- !collect_memory(Type, "", Result).


+!collect_memory(Type, Acc, Result)
    : not memory_item(_, _)[memory(Type)]
    <- Result = Acc.


+!collect_memory(Type, Acc, Result)
    : memory_item(Key, Value)[memory(Type)]
    <-
       .term2string(Key, KS);
       .term2string(Value, VS);

       .concat(KS, " = ", Tmp1);
       .concat(Tmp1, VS, Line);
       .concat(Line, "\n", Line2);

       .concat(Acc, Line2, NewAcc);

       -memory_item(Key, Value)[memory(Type)];
       !collect_memory(Type, NewAcc, Result);
       +memory_item(Key, Value)[memory(Type)].


+!print_memory(Type)
    <- .print("==============================================");
       .print("  [", Type, " MEMORY]");
       .print("==============================================");
       !iterate_memory(Type);
       .print("----------------------------------------------").


+!iterate_memory(Type)
    : not memory_item(_, _)[memory(Type)].


+!iterate_memory(Type)
    : memory_item(Key, Value)[memory(Type)]
    <-
       .print("  KEY      : ", Key);
       .print("  VALUE    : ", Value);
       .print("  ............................................");

       -memory_item(Key, Value)[memory(Type)];
       !iterate_memory(Type);
       +memory_item(Key, Value)[memory(Type)].