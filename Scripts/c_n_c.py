import socket, select, sys

def main():
    # The list contains the file descriptors we'll read from: stdin (keyboard) and the socket we're opening
    cnx_scks = [sys.stdin, socket.socket(socket.AF_INET, socket.SOCK_STREAM)]

    # Let the socket listen on the localhost only! Use '0.0.0.0' a.k.a INADDR_ANY if you have
    # the server and the client in different machines
    cnx_scks[1].bind(('127.0.0.1', 5001))

    # Listen for incoming connections!
    cnx_scks[1].listen(1)

    try:
        while True:
            # The call to select() blocks until all a socket has something we can read
            for sck in select.select(cnx_scks, [], [])[0]:
                # Accept a new connection by spawning a connected socket
                if sck == cnx_scks[1]:
                    cnx_scks.append(sck.accept()[0])
                # Read a instruction from the socket and send it away!
                elif len(cnx_scks) > 1 and sck == sys.stdin:
                    cmd = sys.stdin.readline()
                    cnx_scks[2].sendall(cmd.encode())
                else:
                    # Read the command's output
                    cmd_output = sck.recv(8148).decode()

                    # This particular combination is an EOF: the connected socket has been closed!
                    # Close this end as well and remove it from the list
                    if cmd_output == '':
                        sck.close()
                        cnx_scks.remove(sck)

                    # Otherwise print the output on screen
                    else:
                        for line in cmd_output.split('\n'):
                            print('\t' + line)
    # If the user hits CTRL + C close the sockets and quit
    except KeyboardInterrupt:
        for sck in cnx_scks[1:]:
            sck.close()
        exit(0)
# Launch the server
main()