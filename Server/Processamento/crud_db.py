import pymongo
import bson.objectid

class crud():
    def __init__(self):
        # Host e Porta
        self.host = ""
        self.port = 27017

        self.client = pymongo.MongoClient(self.host, self.port) # Client para fazer conexão ao DB

        self.db = self.client.gamedata # Banco de Dados "gamedata"
        self.db_collection = self.db["data"] # Collection "data"

    def insert(self, data):
        # inserir dados na collection "data"
        self.db_collection.insert_one(data)
    
    def read(self):
        # retorna todos os dados da collection "data"
        collections = self.db_collection.find()

        print("=========usuários cadastrados==========")
        for user in collections:
            print(user)
        print("=======================================")
    
    def update(self, user_to_update, data):
        # Faz update de um usuário cadastrado
        user = self.db_collection.find_one({"username":user_to_update}) # para fazer Update
        user_id = {"_id": bson.ObjectId(user["_id"])}
        update = {"$set":data} # o usuário a receber update

        self.db_collection.update_one(user_id, update)


    def delete(self, username):
        user = self.db_collection.find_one({"username":username})
        self.db_collection.delete_one({"_id":bson.ObjectId(user["_id"])})
        
        print("Usuário deletado!")
