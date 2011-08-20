import structs/HashMap
import Message, BSON, Server, Collection

Database: class {
    server: Server
    name: String

    collections := HashMap<String, Collection> new()

    init: func (=server, =name) {}
    
    getCollection: func (collectionName: String) -> Collection {
        // TODO: cache
        if(!collections contains?(collectionName))
            collections[collectionName] = Collection new(this, collectionName)
        collections[collectionName]
    }
}
