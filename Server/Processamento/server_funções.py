
class Chunck:
    nome = ''
    pos = ''
    tamanho = 0
    tiles = []

class Usuário:

    def criar(self, nome, posX, posY):
        
        self.nome = nome
        self.localização = [posX, posY]
        self.chunck = '1/1'
    
    def alterar_localização(self, posX, posY):
        self.localização[0] = posX
        self.localização[1] = posY

class Protocolos:

    @staticmethod
    def send_chunk(conexão, nome, pacote):
        import socket
        from pickle import loads
        from sqlite_crud import selecionar
        from base64 import b64decode

        pacote = pacote.split(':')[1]
        pacote = pacote.split(".")[0]

        if (len(pacote.split('|')) == 1) and (pacote.split('|')[0] == '0'):
            
            obj = loads(b64decode(selecionar(tabela='contas', v1='binário', v2='nome', v3=nome)))
            chunck = obj.chunck
            
            '''
            chunck = loads(open(f"./chuncks/{chunck}.pkl", 'rb').read())
            '''

            tmp = selecionar(tabela='chuncks', v1='binário', v2='nome', v3=chunck)

            if not tmp:

                conexão.send(b"chunck nao existente")
                return

            chunck = loads(b64decode(tmp))

            saida = f"2:{chunck.nome}|{chunck.pos}|{chunck.tamanho}"
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

            conexão.send(bytes(saida, 'utf-8'))






        elif (len(pacote.split('|')) > 1) and (pacote.split('|')[0] == '1'):

            posX = pacote.split('|')[1].split("/")[0]
            posY = pacote.split('|')[1].split("/")[1]

            tmp = selecionar(tabela='chuncks', v1='binário', v2='nome', v3=f'{posX}/{posY}')

            if not tmp:

                conexão.send(b"chunck nao existente")
                return

            chunck = loads(b64decode(tmp))

            saida = f"2:{chunck.nome}|{chunck.pos}|{chunck.tamanho}"
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

            conexão.send(bytes(saida, 'utf-8'))


def login(pacote):

    import hashlib
    from sqlite_crud import selecionar

    if pacote[0] != '0':
        return ((b"0:0|3.", None) if pacote[3] == 0 else (b"0:1|2.", None))

    pacote = pacote.split(".")[0]
    pacote = pacote.split(":")[1]
    
    modo = pacote.split("|")[0]
    _nome = pacote.split("|")[1]
    senha = pacote.split("|")[2]



    del pacote


    if modo == '0':

        resultado = selecionar(tabela='contas', v1='hash', v2='nome', v3=_nome)
        
        if resultado:

            senha = hashlib.sha256(bytes(senha, 'utf-8')).hexdigest()
            senha_hash = resultado

            if senha == senha_hash: 
                return b"0:0|0.", _nome

            else:
                return b"0:0|1.", None

        else:
            return b"0:0|2.", None

    elif modo == '1':

        from sqlite_crud import selecionar

        resultado = selecionar(tabela='contas', v1='nome', v2='nome', v3=_nome)

        if resultado:
            return b'0:1|1.', None

        else:
            
            from pickle import dumps
            from sqlite_crud import inserir
            from base64 import b64encode

            hash_senha = hashlib.sha256(bytes(senha, 'utf-8')).hexdigest()
            obj = Usuário()
            obj.criar(_nome, 30, 30)
            obj = b64encode(dumps(obj)).decode('utf-8')

            inserir(tabela='contas', valores=[_nome, hash_senha, obj])
            
            return b'0:1|0.', None


