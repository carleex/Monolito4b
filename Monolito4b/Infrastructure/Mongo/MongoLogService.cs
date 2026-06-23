using System;
using System.Collections.Generic;
using System.Linq;
using MongoDB.Driver;

namespace Monolito4b.Infrastructure.Mongo
{
    public class MongoLogService
    {
        private readonly IMongoCollection<MongoLogEntry> _collection;

        public MongoLogService()
        {
            var context = new MongoDbContext();
            _collection = context.GetCollection<MongoLogEntry>("logs");
        }

        public void Registrar(string modulo, string mensaje, string usuario)
        {
            var log = new MongoLogEntry
            {
                Modulo = modulo ?? string.Empty,
                Mensaje = mensaje ?? string.Empty,
                Usuario = usuario ?? string.Empty,
                Fecha = DateTime.UtcNow
            };

            _collection.InsertOne(log);
        }

        public List<MongoLogEntry> ListarRecientes(int cantidad)
        {
            if (cantidad <= 0) cantidad = 20;

            return _collection
                .Find(Builders<MongoLogEntry>.Filter.Empty)
                .SortByDescending(x => x.Fecha)
                .Limit(cantidad)
                .ToList();
        }
    }
}