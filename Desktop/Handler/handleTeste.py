import socket
import threading
import time
def createSocket():
    # inicializa o socket, atribuindo ip e porta
    global host
    global port
    global server
    host = ""
    port = 666
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((host, port))
    server.listen()
    print("UDP server up and listening")




		
createSocket()
def listenClient():
    global conn,addr
    conn, addr = server.accept()
    print('Connected by', addr)
    while True:
        conn.send(b'1:leonardo|3/3')
        time.sleep(3)
        conn.send(b'1:leonardo|4/3')
        data = conn.recv(1024)
        print(data.decode())
listenClient()


thread = threading.Thread(target=hear)
thread.daemon = True
thread.start()


def hear():
    while True:
        a = conn.recv(1024)
        print(a.decode())