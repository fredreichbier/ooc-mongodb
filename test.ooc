import structs/HashBag
import io/FileWriter
import mongodb/[Server,Database, BSON]

main: func {
    server := Server new()
    db := Database new(server, "ooc")
    collection := db getCollection("test")
    doc := HashBag new()
    doc put("i", "did naaaawt")
    fw := FileWriter new(stdout)
    collection find(|query|
        "YESS! %p" printfln(query)
        writeDocument(fw, query getNext())
    )
    server receiveReply()
}
