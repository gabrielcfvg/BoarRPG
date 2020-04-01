import socket
from threading import Thread
import time
import hashlib

from server_funções import Protocolos

dicionario_protocolos = {}
clients_ativos = []
IP = '0.0.0.0'
PORTA = 1234


def remover_client(client):
    clients_ativos.remove(client)
    print(f"cliente desconectou-se {client[1]}")

def receber_do_client(conexão, endereço):


    try:

        nome = ''

        from server_funções import login
        autenticado = False
        while not autenticado:

            pacote = conexão.recv(2048).decode("utf-8")

            resposta, _nome = login(pacote)

            conexão.send(resposta)
            if _nome != None:
                nome = _nome
                autenticado = True


        del login


        while True:

            pacote = conexão.recv(2048).decode('utf-8')
            
            for A in pacote.split("."):

                if len(A) > 0:

                    protocolo = A.split(":")[0]
                    data = A.split(":")[1]

                    dicionario_protocolos[protocolo](conexão, data)


    
    except ConnectionResetError:

        try:
            remover_client([conexão, endereço, nome])   
        except:
            remover_client([conexão, endereço])
            

    else:
        pass
        
def check():

    while True:

        for A in clients_ativos:

            try:
                A[0].send(b'')
            except ConnectionResetError:
                remover_client(A)

        time.sleep(0.3)


sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind((IP, PORTA))
sock.listen()

Thread(target=check, daemon=True).start()

while True:

    conexão, endereço = sock.accept()
    clients_ativos.append([conexão, endereço])
    print("cliente conectado")
    Thread(target=receber_do_client, args=[conexão, endereço], daemon=True).start()
