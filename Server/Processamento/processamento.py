import pymongo
from connection import database

class crud(database):
    def __init__(self):
        super().__init__()

    def insert(self, data):
        # inserir dados na collection "data"
        self.db_collection.insert_one(data)
    
    def read(self):
        # retorna todos os dados da collection "data"
        collections = self.db_collection.find()

        print("\n======================================")
        print("Usuários cadastrados:")
        for user in collections:
            print(user)
        print("======================================\n")
    
    def update(self, data):
        # Faz update de um usuário cadastrado
        data1 = data[0]
        data2 = data[1]

        self.db_collection.update_one(data1,data2)

    def delete(self, id):
        self.db_collection.delete_many({"id":str(id)})
        print(f"Objeto de ID {id} foi deletado")

