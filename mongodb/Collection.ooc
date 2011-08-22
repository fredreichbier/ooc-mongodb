import structs/[HashBag, HashMap]
import Database, Server
import Message into Message
import Cursor

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

    find: func ~simple (selector: HashBag, callback: Func (Exception, Cursor)) {
        msg := Message Query new()
        msg fullCollectionName = fullCollectionName
        msg query = selector
        db server _sendMessage(msg)
        db server registerCallback(msg header requestID, |msg|
            cursor := Cursor new(this, msg)
            callback(null, cursor)
        )
    }

    find: func ~all (callback: Func (Exception, Cursor)) {
        find(HashBag new(), callback)
    }

    delete: func (selector: HashBag) {
        msg := Message Delete new()
        msg fullCollectionName = fullCollectionName
        msg selector = selector
        db server _sendMessage(msg)
    }
}
