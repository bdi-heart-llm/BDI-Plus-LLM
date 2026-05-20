+!perceiveLab <-
    sense;
    .wait(1000);
    !perceiveLab.

+status(K, V) <-
    !update_short_term(K, V).

+status(K, V)<-
 .print("[UPDATE] ", K, " = ", V).