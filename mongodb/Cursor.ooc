import structs/[ArrayList, HashBag]

import Collection, Message

Cursor: class {
    collection: Collection
    reply: Reply
    documents := ArrayList<HashBag> new()
    
    init: func (=collection, =reply) {
        documents addAll(reply documents) 
    }

    getNext: func -> HashBag {
        documents removeAt(0) // TODO: cooler exception?
    }

    hasNext?: func -> Bool {
        documents size > 0
    }
}
