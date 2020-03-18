import pymongo

class database():
    def __init__(self):
        self.host = ""
        self.port = 27017

        self.client = pymongo.MongoClient(self.host, self.port)

        self.db = self.client.gamedata # Banco de Dados "gamedata"
        self.db_collection = self.db["data"] # Collection "data"
