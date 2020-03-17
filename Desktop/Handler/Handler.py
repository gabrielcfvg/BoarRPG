import socket
import threading


sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind(("127.0.0.1", 1234))
sock.listen(5)

class Funções_de_Protocolos:

    @staticmethod
    def login(mensagem, conexão):

        valores = mensagem.split("|")
        
        usuario = valores[0]
        senha = valores[1]
        modo = valores[2]

        del valores

        if usuario == senha:

            conexão.send(bytes("1:1", "utf-8"))

        else:
            conexão.send(bytes("1:0", "utf-8"))

enumeração_de_funções = {1: Funções_de_Protocolos.login}

def Parser(conexão, endereço):

    try:

        pacote = conexão.recv(2048).decode("utf-8")
        
        

        protocolo = int(pacote.split(":")[0])
        mensagem = pacote.split(":")[1]
        enumeração_de_funções[protocolo](mensagem, conexão)

    except ConnectionResetError as error:
        print(error)

print("------------")
print("server ativo")
print("------------\n\n")

while True:
    print("S")
    conexão, endereço = sock.accept()
    threading.Thread(target=Parser, args=[conexão, endereço]).start()
