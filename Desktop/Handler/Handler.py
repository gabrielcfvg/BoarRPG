import socket
import threading
import requests

LINK = "http://127.0.0.1:5000/"
#LINK = "https://testeflask--gabrielcl.repl.co/"


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(("127.0.0.1", 1234))

class Funções_de_Protocolos:

    @staticmethod
    def login(mensagem, endereço):

        valores = mensagem.split("|")
        
        usuario = valores[0]
        senha = valores[1]
        modo = valores[2]

        del valores

        senha_server = str(requests.get(f"{LINK}1:{usuario}").text).strip()
        
        print(senha, senha_server)
        print(len(senha), len(senha_server))


        if senha_server == senha:
            socket.socket(socket.AF_INET, socket.SOCK_DGRAM).sendto(b"1:1", endereço)
            print("A")

        else:
            socket.socket(socket.AF_INET, socket.SOCK_DGRAM).sendto(b"1:0", endereço)

    @staticmethod
    def checar_vida(mensagem, endereço):

        vida = str(requests.get(f"{LINK}2:None").text).strip()
        socket.socket(socket.AF_INET, socket.SOCK_DGRAM).sendto(bytes(f"2:{vida}", 'utf-8'), endereço)



enumeração_de_funções = {1: Funções_de_Protocolos.login, 2: Funções_de_Protocolos.checar_vida}

def Parser(data, endereço):

    

    pacote = data.decode("utf-8")
    

    protocolo = int(pacote.split(":")[0])
    mensagem = pacote.split(":")[1]
    enumeração_de_funções[protocolo](mensagem, endereço)



print("------------")
print("server ativo")
print("------------\n\n")


while True:
    
    data, endereço = sock.recvfrom(2048)
    print("S")
    threading.Thread(target=Parser, args=[data, endereço]).start()
