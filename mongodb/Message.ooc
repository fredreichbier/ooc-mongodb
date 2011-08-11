import io/BinarySequence

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

WireObject: abstract class {
    toWire: func (writer: BinarySequenceWriter)
    fromWire: func (reader: BinarySequenceReader)
}

MessageHeader: class extends WireObject {
    messageLength, requestID, responseTo, opCode: Int32

    init: func {}

    toWire: func (writer: BinarySequenceWriter) {
        writer s32(messageLength)
              .s32(requestID)
              .s32(responseTo)
              .s32(opCode)  
    }

    fromWire: func (reader: BinarySequenceReader) {
        messageLength = reader s32()
        requestID = reader s32()
        responseTo = reader s32()
        opCode = reader s32()
    }
}

InsertFlags: enum {
    continueOnError = 1
}

// write-only
Insert: class extends WireObject {
    header: MessageHeader
    flags: Int32
    fullCollectionName: String

    init: func (=header) {}

    toWire: func (writer: BinarySequenceWriter) {
        header toWire(writer)
        writer s32(flags)
              .cString(fullCollectionName)
                // TODO... 
    }
}

