from threading import Thread
import socket
from base64 import b64decode, b64encode
from pickle import loads, dumps
from traceback import print_exc

from server_funções import Usuário, Chunck


##################################################################################################################
#                                                                                                                #
#                                             Funções e Classes                                                  #
#                                                                                                                #
##################################################################################################################


class Funções:

    @staticmethod
    def thread_decorador(func):

        def main(chave, pacote):

            Thread(target=func, args=[chave, pacote], daemon=True).start()

        return main

    @staticmethod
    def gerar_chave(chave_inicial):
        from random import randint

        chave = chave_inicial+str(randint(1, 9))

        if chave in clients_ativos:
            return Funções.gerar_chave(chave)
        else:
            return chave

    @staticmethod
    def login(chave, conexão):

        from server_funções import login
        from sqlite_crud import selecionar

        autenticado = False
        while not autenticado:

            pacote = conexão.recv(2048).decode("utf-8")

            if len(pacote) == 0:
                Funções.pacote_nulo(chave, clients_ativos[chave]['endereço'], None)
                raise Exception

            print("pacote login:", pacote) 
            resposta, _nome = login(pacote)
            conexão.send(resposta)

            if _nome != None:
                nome = _nome
                clients_ativos[chave]['nome'] = nome
                autenticado = True

                obj = loads(b64decode(selecionar(tabela='contas', v1='binário', v2='nome', v3=nome)))
                clients_ativos[chave]['objeto'] = obj

    @staticmethod
    def remover_client(chave):
        from sqlite_crud import atualizar

        if not chave in clients_ativos:
            return

        if len(clients_ativos[chave]) == 4:

            obj = b64encode(dumps(clients_ativos[chave]['objeto'])).decode('utf-8')
            nome = clients_ativos[chave]['nome']

            atualizar(tabela='contas', v1='binário', v2=obj, v3='nome', v4=nome)


        del clients_ativos[chave]

    @staticmethod
    def pacote_nulo(chave, endereço, nome):

        print(f"Usuário desconectado |{nome if nome else 'indefinido'}| {endereço}  motivo = Pacote Nulo")
        try:
            Funções.remover_client(chave)   
        except:
            Funções.remover_client(chave)

    @staticmethod
    def chunck_players(chave):

        nome = clients_ativos[chave]['nome']
        chunck = clients_ativos[chave]['objeto'].chunck

        for A in clients_ativos:

            if A in clients_ativos:

                if clients_ativos[A]["nome"] != nome and clients_ativos[A]["objeto"].chunck == chunck:

                    sock_UDP.sendto(bytes(f"1:{clients_ativos[A]['nome']}|{clients_ativos[A]['objeto'].localização}.", 'utf-8'), (clients_ativos[chave]['endereço'][0], 666))

class Protocolos:

    @staticmethod
    @Funções.thread_decorador
    def enviar_movimentação(chave, pacote):

        nome = clients_ativos[chave]['nome']
        pacote = pacote.split(":")[1]
        chunck = clients_ativos[chave]['objeto'].chunck

        for A in clients_ativos:
            
            if A in clients_ativos:
                
                if clients_ativos[A]['nome'] != nome and clients_ativos[A]['objeto'].chunck == chunck:

                    #print('----------> ', clients_ativos[A]['nome'])

                    sock_UDP.sendto(bytes(f"1:{nome}|{pacote}.", 'utf-8'), (clients_ativos[A]["endereço"][0], 666))

        
        clients_ativos[chave]['objeto'].localização = pacote

    @staticmethod
    def send_chunk(chave, pacote):

        from sqlite_crud import selecionar
        

        conexão = clients_ativos[chave]['conexão']
        nome = clients_ativos[chave]['nome']
        pacote = pacote.split(':')[1]

        if (pacote.split('|')[0] == '0'):
            
            obj = loads(b64decode(selecionar(tabela='contas', v1='binário', v2='nome', v3=nome)))
            chunck_name = obj.chunck

            tmp = selecionar(tabela='chuncks', v1='binário', v2='nome', v3=chunck_name)

            if not tmp:

                conexão.send(b"chunck nao existente")
                return

            chunck = loads(b64decode(tmp))

            saida = f"2:{chunck.nome}|{chunck.pos}|{chunck.tamanho}|{clients_ativos[chave]['objeto'].localização}"
            for A in chunck.tiles:
                for B in A:
                    
                    tipo = B["tipo"]
                    sprite = B["sprite"]
                    info = ''
                    if len(B["informações"]) == 0:
                        info = 'n'
                    else:
                        for C in B["informações"]:
                            info += C+"|"
                        info = info[:-1]

                    saida += f"|{tipo}/{sprite}/{info}"

            saida += '.'
            
            clients_ativos[chave]['objeto'].chunck = chunck_name
            conexão.send(bytes(saida, 'utf-8'))


        elif (len(pacote.split('|')) > 1) and (pacote.split('|')[0] == '1'):

            posX = pacote.split('|')[1].split("/")[0]
            posY = pacote.split('|')[1].split("/")[1]
            chunck_name = f'{posX}/{posY}'
            tmp = selecionar(tabela='chuncks', v1='binário', v2='nome', v3=f'{chunck_name}')

            if not tmp:

                conexão.send(b"chunck nao existente")
                return

            chunck = loads(b64decode(tmp))

            saida = f"2:{chunck.nome}|{chunck.pos}|{chunck.tamanho}|{clients_ativos[chave]['objeto'].localização}"
            for A in chunck.tiles:
                for B in A:
                    
                    tipo = B["tipo"]
                    sprite = B["sprite"]
                    info = ''
                    if len(B["informações"]) == 0:
                        info = 'n'
                    else:
                        for C in B["informações"]:
                            info += C+"|"
                        info = info[:-1]

                    saida += f"|{tipo}/{sprite}/{info}"

            saida += '.'

            clients_ativos[chave]['objeto'].chunck = chunck_name
            conexão.send(bytes(saida, 'utf-8'))

            Funções.chunck_players(chave)


def receber(chave, conexão, endereço):
 
    try:        
        nome = "indefinido"

        Funções.login(chave, conexão)

        nome = clients_ativos[chave]['nome']

        
        while True:

            pacote = conexão.recv(2048).decode('utf-8')
            
            print("Pacote recebido")
            print("Pacote: ", pacote)

            if len(pacote) == 0:
                Funções.pacote_nulo(chave, endereço, nome)
                break


            for A in pacote.split("."):

                if len(A) > 0:
                    print(f"comando: |{A}|")
                    
                    protocolo = (A.split(":")[0])
                    dicionario_protocolos[protocolo](chave, A)

    except ConnectionResetError:
        
        print(f"Usuário desconectado |{nome}| {endereço}  motivo = ConnectionResetError")
        Funções.remover_client(chave)   

    except Exception as erro:
        
        print(f"Usuário desconectado |{nome}| {endereço} motivo = desconhecido")
        print(f"erro: |{erro}|")
        print_exc()
        Funções.remover_client(chave)



##################################################################################################################
#                                                                                                                #
#                                    Declaração de variaveis e constantes                                        #
#                                                                                                                #
##################################################################################################################

dicionario_protocolos = {'1': Protocolos.enviar_movimentação, '2': Protocolos.send_chunk}
clients_ativos = {}
IP = '0.0.0.0'
PORTA = 1234

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock_UDP = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

##################################################################################################################
#                                                                                                                #
#                                             Programa principal                                                 #
#                                                                                                                #
##################################################################################################################

sock.bind((IP, PORTA))
sock.listen()

while True:

    conexão, endereço = sock.accept()
    print("cliente conectado:", endereço)
    
    chave = Funções.gerar_chave(endereço[0])
    clients_ativos[chave] = {'conexão': conexão, 'endereço': endereço}
    
    Thread(target=receber, args=[chave, conexão, endereço], daemon=True).start()
