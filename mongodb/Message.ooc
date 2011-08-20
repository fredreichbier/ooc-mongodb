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

WireObject: abstract class {
    toWire: func (writer: BinarySequenceWriter)
    fromWire: func (reader: BinarySequenceReader)
    getSize: func -> Int32 { -1 }
}

generateRequestId: func -> Int32 {
    id: static Int32 = 1337
    return id % 4294967295
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
