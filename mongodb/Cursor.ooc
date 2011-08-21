import structs/[ArrayList, HashBag]

import Collection
import Message

Cursor: class {
    collection: Collection
    reply: Reply
    documents := ArrayList<HashBag> new()
    
    init: func (=collection, =reply) {
        documents addAll(reply documents) 
    }

    canFetchMore: Bool {
        get {
            reply cursorID != 0
        }
    }

    _fetchMore: func (cb: Func) {
        // we got a cursor ID, let's fetch more!
        msg := GetMore new()
        msg fullCollectionName = collection fullCollectionName
        msg cursorID = reply cursorID
        collection db server _sendMessage(msg)
        collection db server registerCallback(msg header requestID, |reply|
            this reply = reply
            this documents addAll(reply documents)
            cb()
        )
    }

    getNext: func (fn: Func (Exception, HashBag)) {
        if(documents size == 0) {
            // nothing's left! aragrgaragrhargarhargh
            // can we fetch it?
            if(canFetchMore) {
                // yessss, fetch et!
                _fetchMore(||
                    getNext(fn)
                )
                return
            } else {
                fn(Exception new(This, "I'm exhausted, honey."), null)
                return
            }
        }
        fn(null, documents removeAt(0)) // TODO: cooler exception?
    }

    hasNext?: func -> Bool {
        canFetchMore ? true : documents size > 0
    }

    each: func (fn: Func (Exception, HashBag)) {
        while(documents size > 0)
            getNext(fn)
        if(canFetchMore)
            _fetchMore(||
                each(fn) // TODO: we should do some hacky-hacky not to overflow the stacky-stacky
            )
    }
}
