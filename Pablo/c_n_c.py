import socket, select, sys

def main():
    cnx_scks = [sys.stdin, socket.socket(socket.AF_INET, socket.SOCK_STREAM)]
    cnx_scks[1].bind(('127.0.0.1', 5001))
    cnx_scks[1].listen(1)

    try:
        while True:
            for sck in select.select(cnx_scks, [], [])[0]:
                if sck == cnx_scks[1]:
                    cnx_scks.append(sck.accept()[0])
                elif len(cnx_scks) > 1 and sck == sys.stdin:
                    cmd = sys.stdin.readline()
                    cnx_scks[2].sendall(cmd.encode())
                else:
                    cmd_output = sck.recv(8148).decode()
                    if cmd_output == '':
                        sck.close()
                        cnx_scks.remove(sck)
                    else:
                        for line in cmd_output.split('\n'):
                            print('\t' + line)
    except KeyboardInterrupt:
        for sck in cnx_scks:
            sck.close()
        exit(0)

main()