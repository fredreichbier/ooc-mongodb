import structs/HashBag
import io/FileWriter
import mongodb/[Server,Database, BSON]

stdoutWriter := FileWriter new(stdout)

main: func {
    server := Server new()
    db := Database new(server, "ooc")
    collection := db getCollection("cool")
    collection find(|err, query|
        query each(|err, doc|
            writeDocument(stdoutWriter, doc)
            "" println()
        )
    )
    while(true)
        server receiveReply()
}
