import io/[BinarySequence, Writer, BufferWriter]
import structs/[HashBag, ArrayList]
import BSON into BSON

OpCode: enum {
    reply = 1
    msg = 1000
    update = 2001
    insert = 2002
    reserved = 2003
    query = 2004
    getMore = 2005
    delete = 2006
    killCursors = 2007
}

writeBSON: func (value: HashBag, seq: BinarySequenceWriter) {
    bson := BSON Builder new(seq)
    bson writeDocument(value)
}

readBSON: func (reader: BinarySequenceReader) -> (HashBag, SizeT) {
    bson := BSON Parser new(reader)
    bson readAll()
    (bson document, bson size)
}

WireObject: abstract class {
    toWire: func (writer: BinarySequenceWriter)
    fromWire: func (reader: BinarySequenceReader)
    getSize: func -> Int32 { -1 }
}

generateRequestId: func -> Int32 {
    id: static Int32 = 1336
    id += 1
    return id
}

MessageHeader: class extends WireObject {
    messageLength, requestID, responseTo, opCode: Int32

    init: func {}

    toWire: func (writer: BinarySequenceWriter) {
        writer s32(messageLength) \
              .s32(requestID) \
              .s32(responseTo) \
              .s32(opCode)
    }

    fromWire: func (reader: BinarySequenceReader) {
        messageLength = reader s32()
        requestID = reader s32()
        responseTo = reader s32()
        opCode = reader s32()
    }

    getSize: func -> Int32 {
        4 * (Int32 size)
    }
}

InsertFlags: enum {
    continueOnError = 1
}

createBinarySequence: func -> (Buffer, BinarySequenceWriter) {
    buf := Buffer new()
    writer := BufferWriter new(buf)
    sequence := BinarySequenceWriter new(writer)
    (buf, sequence)
}

// write-only
Insert: class extends WireObject {
    header := MessageHeader new()
    flags: Int32 = 0
    fullCollectionName: String = ""
    documents := ArrayList<HashBag> new()

    init: func () {}

    addDocument: func (doc: HashBag) {
        documents add(doc)
    }

    toWire: func (writer: BinarySequenceWriter) {
        // first write the body ...
        (buf, seq) := createBinarySequence()
        seq s32(flags) \
              .cString(fullCollectionName)
        for(doc in documents)
            writeBSON(doc, seq)
        // then calculate the size (including header)
        header messageLength = buf size + header getSize()
        header requestID = generateRequestId()
        header responseTo = 0
        header opCode = OpCode insert as Int32
        header toWire(writer)
        writer writer write(buf)
    }
}

// write-only
Update: class extends WireObject {
    header := MessageHeader new()
    fullCollectionName: String = ""
    flags: Int32 = 0
    selector, update: HashBag

    init: func {}
    
    toWire: func (writer: BinarySequenceWriter) {
        // write the body first
        (buf, seq) := createBinarySequence()
        seq s32(0) \
           .cString(fullCollectionName) \
           .s32(flags)
        writeBSON(selector, seq)
        writeBSON(update, seq)
        header messageLength = buf size + header getSize()
        header requestID = generateRequestId()
        header responseTo = 0
        header opCode = OpCode update as Int32
        header toWire(writer)
        writer writer write(buf)
    }
}

UpdateFlags: enum {
    upsert = 1
    multiInsert = 2
}

Query: class extends WireObject {
    header := MessageHeader new()
    flags: Int32 = 0
    fullCollectionName: String = ""
    numberToSkip: Int32 = 0
    numberToReturn: Int32 = 0
    query: HashBag
    returnFieldSelector: HashBag = null

    init: func () {}

    toWire: func (writer: BinarySequenceWriter) {
        (buf, seq) := createBinarySequence()
        numberToReturn = 30
        seq s32(flags) \
           .cString(fullCollectionName) \
           .s32(numberToSkip) \
           .s32(numberToReturn)
        writeBSON(query, seq)
        if(returnFieldSelector != null)
            writeBSON(returnFieldSelector, seq)
        header messageLength = buf size + header getSize()
        header requestID = generateRequestId()
        header responseTo = 0
        header opCode = OpCode query as Int32
        header toWire(writer)
        writer writer write(buf)
    }
}

QueryFlags: enum {
    tailableCursor = 2
    slaveOk = 4
    oplogReplay = 8
    noCursorTimeout = 16
    awaitData = 32
    exhaust = 64
    partial = 128
}

Reply: class extends WireObject {
    header := MessageHeader new()
    responseFlags: Int32
    cursorID: Int64
    startingFrom, numberReturned: Int32
    documents := ArrayList<HashBag> new()

    init: func () {}

    fromWire: func (reader: BinarySequenceReader) {
        header fromWire(reader)
        responseFlags = reader s32() // 4
        cursorID = reader s64() // 8 
        startingFrom = reader s32() // 4
        numberReturned = reader s32() // 4
        reader bytesRead = 0 // TODO: wow that's kind of ugly! but needed for the remainingBytes calculation.
        remainingBytes := header messageLength - header getSize() - (4 + 8 + 4 + 4)
        while(remainingBytes > 0) {
            (doc, size) := readBSON(reader)
            documents add(doc)
            remainingBytes -= size
        }
    }
}

GetMore: class extends WireObject {
    header := MessageHeader new()
    fullCollectionName: String
    numberToReturn: Int32
    cursorID: Int64

    init: func {}

    toWire: func (writer: BinarySequenceWriter) {
        (buf, seq) := createBinarySequence()
        seq s32(0) \
           .cString(fullCollectionName) \
           .s32(numberToReturn) \
           .s64(cursorID)
        header messageLength = buf size + header getSize()
        header requestID = generateRequestId()
        header responseTo = 0
        header opCode = OpCode getMore as Int32
        header toWire(writer)
        writer writer write(buf)
    }
}


KillCursors: class extends WireObject {
    header := MessageHeader new()
    cursorIDs := ArrayList<Int64> new()

    init: func {}

    addCursorID: func (cursorID: Int64) {
        cursorIDs add(cursorID)
    }

    toWire: func (writer: BinarySequenceWriter) {
        (buf, seq) := createBinarySequence()
        seq s32(0) \
           .s32(cursorIDs size)
        for(cursorID in cursorIDs)
            seq s32(cursorID)
        header messageLength = buf size + header getSize()
        header requestID = generateRequestId()
        header responseTo = 0
        header opCode = OpCode killCursors as Int32
        header toWire(writer)
        writer writer write(buf)
    }
}

Delete: class extends WireObject {
    header := MessageHeader new()
    fullCollectionName: String
    flags: Int32
    selector: HashBag

    init: func {}

    toWire: func (writer: BinarySequenceWriter) {
        (buf, seq) := createBinarySequence()
        seq s32(0) \
           .cString(fullCollectionName) \
           .s32(flags)
        writeBSON(selector, seq)
        header messageLength = buf size + header getSize()
        header requestID = generateRequestId()
        header responseTo = 0
        header opCode = OpCode delete as Int32
        header toWire(writer)
        writer writer write(buf)
    }
}

DeleteFlags: enum {
    singleRemove = 1
}
