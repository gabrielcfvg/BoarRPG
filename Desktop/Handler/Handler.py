import socket
import threading


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

        print("a")

        print(endereço)

        if usuario == senha:
            temp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM).sendto(b"1:1", endereço)

        else:
            temp = socket.socket(socket.AF_INET, socket.SOCK_DGRAM).sendto(b"1:0", endereço)


enumeração_de_funções = {1: Funções_de_Protocolos.login}

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
