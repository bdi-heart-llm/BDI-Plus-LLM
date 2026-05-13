import socket
import threading

HOST = "127.0.0.1"
PORT = 5000

def receive_loop(conn):
    """Continuously listen for agent responses in background."""
    while True:
        try:
            data = conn.recv(1024)
            if not data:
                print("\n[Disconnected]")
                break
            print(f"\nAgent: {data.decode().strip()}\nYou: ", end="", flush=True)
        except:
            break

if __name__ == '__main__':
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((HOST, PORT))
    server.listen(1)
    print(f"Waiting for agent on {HOST}:{PORT}...")

    conn, addr = server.accept()
    print(f"Connected: {addr}")

    # Start background thread for incoming responses
    t = threading.Thread(target=receive_loop, args=(conn,), daemon=True)
    t.start()

    # Main thread handles user input
    print("Type messages (enter to send, 'exit' to quit):")
    while True:
        msg = input("You: ")
        if msg.lower() == "exit":
            break
        conn.sendall((msg + "\n").encode())

    conn.close()