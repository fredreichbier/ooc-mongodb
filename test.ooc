import structs/HashBag
import io/FileWriter
import mongodb/[Server,Database, BSON]

stdoutWriter := FileWriter new(stdout)

main: func {
    server := Server new()
    db := Database new(server, "ooc")
    collection := db getCollection("cool")
    sel := HashBag new()
    sel put("level", 30.0)
    collection delete(sel)
    collection find(|err, query|
        query each(|err, doc|
            writeDocument(stdoutWriter, doc)
            "" println()
        )
    )
    while(true)
        server receiveReply()
}
