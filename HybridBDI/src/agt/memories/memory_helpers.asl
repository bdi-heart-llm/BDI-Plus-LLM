+!add_memory(Type, Key, Value)
    <- +memory_item(Key, Value)[memory(Type)].
+!remove_memory(Type, Key, Value)
    <- -memory_item(Key, Value)[memory(Type)].

+!memory_to_text(Type, Result)
    <- .findall([K,V], memory_item(K,V)[memory(Type)], L);
       !list(L, Type, "", Result).

+!list([], _, Acc, Acc).

+!list([[K,V]|T], Type, Acc, Result)
    <- .term2string(K, KS);
       .term2string(V, VS);

       if (memory_item(K,V)[memory(Type), description(D)]) {
           .term2string(D, DS);
           .concat(KS," = ",T1);
           .concat(T1,VS,T2);
           .concat(T2," // ",T3);
           .concat(T3,DS,Line);
       } else {
           .concat(KS," = ",T1);
           .concat(T1,VS,Line);
       };

       .concat(Acc,Line,"\n",Acc2);
       !list(T,Type,Acc2,Result).