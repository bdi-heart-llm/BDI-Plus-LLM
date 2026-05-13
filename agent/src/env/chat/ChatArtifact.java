package chat;

import cartago.Artifact;
import cartago.INTERNAL_OPERATION;
import cartago.OPERATION;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class ChatArtifact extends Artifact {
    private Socket socket;
    private BufferedReader in;
    private PrintWriter out;

    private Thread listener;

    @OPERATION
    void connect(String host, int port) {
        try {
            socket = new Socket(host, port);
            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            out = new PrintWriter(socket.getOutputStream(), true);

            listener = new Thread(() -> {
                try {
                    String line;
                    while ((line = in.readLine()) != null) {
                        execInternalOp("listenLoop", line);
                    }
                } catch (Exception e) {
                    // socket closed normally or error
                }
            });
            listener.setDaemon(true); // don't block JVM shutdown
            listener.start();

            signal("connected");
        } catch (Exception e) {
            failed("connection_failed");
        }
    }

    @INTERNAL_OPERATION
    void listenLoop(String line) {
        signal("new_text", line);
    }

    @OPERATION
    void sendText(String msg) {
        if (out == null || socket == null || socket.isClosed()) {
            failed("not_connected");
            return;
        }
        out.println(msg);
        if (out.checkError()) {   // PrintWriter swallows exceptions; checkError() catches them
            failed("send_failed");
        }
    }

    @OPERATION
    void disconnect() {
        try {
            if (socket != null) socket.close();
            signal("disconnected");
        } catch (Exception e) {
            failed("disconnect_failed");
        }
    }
}