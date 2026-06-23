using System;
using System.Configuration;
using MongoDB.Driver;

namespace Monolito4b.Infrastructure.Mongo
{
    public class MongoDbContext
    {
        private static readonly Lazy<IMongoDatabase> _database = new Lazy<IMongoDatabase>(CreateDatabase);

        public IMongoDatabase Database
        {
            get { return _database.Value; }
        }

        public IMongoCollection<T> GetCollection<T>(string collectionName)
        {
            if (string.IsNullOrWhiteSpace(collectionName))
                throw new ArgumentException("collectionName no puede estar vacío.");

            return Database.GetCollection<T>(collectionName);
        }

        private static IMongoDatabase CreateDatabase()
        {
            string connectionString = ConfigurationManager.AppSettings["MongoConnectionString"];
            string databaseName = ConfigurationManager.AppSettings["MongoDatabaseName"];

            if (string.IsNullOrWhiteSpace(connectionString))
                throw new ConfigurationErrorsException("Falta appSettings['MongoConnectionString'] en Web.config.");

            if (string.IsNullOrWhiteSpace(databaseName))
                throw new ConfigurationErrorsException("Falta appSettings['MongoDatabaseName'] en Web.config.");

            var client = new MongoClient(connectionString);
            return client.GetDatabase(databaseName);
        }
    }
}