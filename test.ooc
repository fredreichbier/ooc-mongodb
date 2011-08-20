import structs/HashBag
import mongodb/[Server,Database]

main: func {
    server := Server new()
    db := Database new(server, "ooc")
    collection := db getCollection("test")
    doc := HashBag new()
    doc put("i", "did naaaawt")
    collection insert(doc)
}
