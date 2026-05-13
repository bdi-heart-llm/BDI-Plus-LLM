package lab;

import cartago.*;

import java.util.LinkedHashMap;
import java.util.Map;

@ARTIFACT_INFO(
        outports = {
                @OUTPORT(name = "lab-td")
        }
) public class Lab extends Artifact {
    private final Map<String, ObsProperty> obsProps = new LinkedHashMap<>();

    public void init(){
    }

    @OPERATION
    void sense(){
        OpFeedbackParam<Object[]>  keys   = new OpFeedbackParam<>();
        OpFeedbackParam<Object[]>  values = new OpFeedbackParam<>();
        try {
            execLinkedOp("lab-td", "readProperty", "Status", keys, values);
            updateMap(keys.get(), values.get());
        } catch (OperationException e) {
            throw new RuntimeException(e);
        }
    }

    private void updateMap(Object[] keys, Object[] values) {
        if (keys == null || values == null) return;

        for (int i = 0; i < keys.length; i++) {
            String k = keys[i].toString();
            Object v = values[i];

            if (!obsProps.containsKey(k)) {

                ObsProperty p = defineObsProperty("status", k, v);
                obsProps.put(k, p);
                //log("NEW   " + k + " = " + v);

            } else {
                ObsProperty p = obsProps.get(k);
                Object current = p.getValue(1);

                if (!current.equals(v)) {
                    // Changed → belief updated automatically (-status(K,Old) +status(K,New))
                    p.updateValues(k, v);
                    // log("UPDATE " + k + ": " + current + " → " + v);
                }
                // Unchanged → no event fired, belief untouched
            }
        }
    }
}