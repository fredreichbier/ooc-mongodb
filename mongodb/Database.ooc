import structs/HashMap
import Server
import Message, BSON, Collection

Database: class {
    _server: Pointer //Server
    name: String

    collections := HashMap<String, Collection> new()

    init: func (=_server, =name) {}

    server: Server { /* ugly workaround, but if we just access `_server`, gcc dies because `Server` is an incomplete type */
        get { _server as Server }
    }
    
    getCollection: func (collectionName: String) -> Collection {
        // TODO: cache
        if(!collections contains?(collectionName))
            collections[collectionName] = Collection new(this, collectionName)
        collections[collectionName]
    }
}
