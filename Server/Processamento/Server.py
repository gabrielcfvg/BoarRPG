from threading import Thread
from time import sleep
import socket
from server_funções import Protocolos, Usuário, Chunck

class Protocolos_local:

    @staticmethod
    def enviar_movimentação(conexão, nome, comando):

        loc = comando.split(':')[1]

        for A in clients_ativos:
            if A[2] != nome:
                A[0].send(bytes(f"1:{nome}|{loc}.", 'utf-8'))

dicionario_protocolos = {'2': Protocolos.send_chunk, '1': Protocolos_local.enviar_movimentação}
clients_ativos = []
IP = '0.0.0.0'
PORTA = 1234

class Funções:

    @staticmethod
    def remover_client(client):
        clients_ativos.remove(client)

    @staticmethod
    def pacote_nulo(conexão, endereço, nome):
        
        print(f"Usuário desconectado |{nome}| {endereço}  motivo = Pacote Nulo")
        try:
            Funções.remover_client([conexão, endereço, nome])   
        except:
            Funções.remover_client([conexão, endereço])
    

def receber(conexão, endereço):

    nome = ''

    try:
        
        from server_funções import login
        autenticado = False
        while not autenticado:

            pacote = conexão.recv(2048).decode("utf-8")
            if len(pacote) == 0:
                Funções.pacote_nulo(conexão, endereço, nome)
                break
            print("loginpacote: ", pacote)
            resposta, _nome = login(pacote)
            conexão.send(resposta)
            if _nome != None:
                nome = _nome
                clients_ativos[clients_ativos.index([conexão, endereço])].append(nome)
                autenticado = True

        del login

        while autenticado:
            
            pacote = conexão.recv(2048).decode('utf-8')
            print("Pacote recebido")
            print("Pacote: ", pacote)
            if len(pacote) == 0:
                Funções.pacote_nulo(conexão, endereço, nome)
                break


            for A in pacote.split("."):

                if len(A) > 0:
                    print(f"comando: |{A}|")
                    protocolo = (A.split(":")[0])
                    dicionario_protocolos[protocolo](conexão, nome, A)


    except ConnectionResetError:
        
        print(f"Usuário desconectado |{nome}| {endereço}  motivo = ConnectionResetError")
        try:
            Funções.remover_client([conexão, endereço, nome])   
        except:
            Funções.remover_client([conexão, endereço])
    
    except Exception as erro:
        
        print(f"Usuário desconectado |{nome}| {endereço} motivo = desconhecido")
        print(f"erro: |{erro}|")
        try:
            Funções.remover_client([conexão, endereço, nome])   
        except:
            Funções.remover_client([conexão, endereço])


#================================================================================
#================================================================================

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind((IP, PORTA))
sock.listen()

while True:

    conexão, endereço = sock.accept()
    print("cliente conectado:", endereço)
    clients_ativos.append([conexão, endereço])
    Thread(target=receber, args=[conexão, endereço], daemon=True).start()
