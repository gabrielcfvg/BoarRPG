class Protocolos:

    @staticmethod
    def teste():
        pass



def login(pacote):

    import hashlib
    
    pacote = pacote.split(":")[1]
    print(pacote)

    modo = pacote.split("|")[0]
    _nome = pacote.split("|")[1]
    senha = pacote.split("|")[2]

    del pacote


    if modo == '0':
        
        existe = False
        for A in open("logins.csv", 'r', encoding="utf-8").readlines():
            if A.split(";")[0].startswith(_nome):
                existe = A
                break
        
        if existe:

            senha = hashlib.sha256(bytes(senha, 'utf-8')).hexdigest()
            senha_hash = existe.split(";")[1].strip()


            if senha == senha_hash: 
                return b"0:0|0", _nome

            else:
                return b"0:0|1", None

        else:
            return b"0:0|2", None

    elif modo == '1':

        existe = False
        for A in open("logins.csv", 'r', encoding="utf-8").readlines():
            if A.split(";")[0] == _nome:
                existe = True
                break

        if existe:
            return b'0:1|1', None

        else:
            open("logins.csv", 'a', encoding='utf-8').write(f"\n{_nome};{hashlib.sha256(bytes(senha, 'utf-8')).hexdigest()}")
            return b'0:1|0', None