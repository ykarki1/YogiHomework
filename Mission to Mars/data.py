import pymongo

# Setup connection to mongodb
conn = "mongodb://localhost:27017"
client = pymongo.MongoClient(conn)

# Select database and collection to use
db = client.mars_db
collection = db.mars_data

db.mars_data.insert_many(
# Create an instance of our Flask app