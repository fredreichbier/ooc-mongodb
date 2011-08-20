import structs/HashBag
import Database, Server
import Message into Message

Collection: class {
    db: Database
    name: String
    fullCollectionName: String

    init: func (=db, =name) {
        fullCollectionName = db name + "." + name
    }

    insert: func (documents: ...) {
        msg := Message Insert new()
        msg fullCollectionName = fullCollectionName
        documents each(|doc|
            msg addDocument(doc as HashBag)
        )
        db server _sendMessage(msg)
    }
}
