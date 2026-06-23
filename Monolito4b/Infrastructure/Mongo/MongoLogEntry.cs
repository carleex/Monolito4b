using System;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Monolito4b.Infrastructure.Mongo
{
    public class MongoLogEntry
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; }

        [BsonElement("modulo")]
        public string Modulo { get; set; }

        [BsonElement("mensaje")]
        public string Mensaje { get; set; }

        [BsonElement("usuario")]
        public string Usuario { get; set; }

        [BsonElement("fecha")]
        public DateTime Fecha { get; set; }
    }
}