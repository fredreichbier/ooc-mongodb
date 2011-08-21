import net/[Address, StreamSocket]
import io/BinarySequence
import structs/HashMap

import Message

Callback: class { /* workaround because HashMap<Int32, Func (Reply)> likes to segfault. */
    fn: Func (Reply)

    init: func (=fn) {}
    invoke: func (reply: Reply) { fn(reply) }
}

Server: class {
    addr: SocketAddress

    socket: StreamSocket
    reader: StreamSocketReader
    writer: StreamSocketWriter

    binaryWriter: BinarySequenceWriter
    binaryReader: BinarySequenceReader

    callbacks := HashMap<Int32, Callback> new()

    init: func (=addr) {
        socket = StreamSocket new(addr)
        reader = socket reader()
        writer = socket writer()
        binaryWriter = BinarySequenceWriter new(writer)
        binaryReader = BinarySequenceReader new(reader)
        socket connect()
    }

    init: func ~withHostPort (host: String, port: UInt) {
        ip := IP4Address new(host)
        init(SocketAddress new(ip, port))
    }

    init: func ~default {
        init("localhost", 27017)
    }

    _sendMessage: func (msg: WireObject) {
        msg toWire(binaryWriter)
    }

    registerCallback: func (requestID: Int32, fn: Func (Reply)) {
        // TODO: check if there is already a callback for that request ID. If that's the case, die.
        cb := Callback new(fn)
        callbacks put(requestID, cb)
    }

    receiveReply: func {
        msg := Reply new()
        msg fromWire(binaryReader)
        invokeCallback(msg)
    }

    invokeCallback: func (msg: Reply) {
        // TODO: let's have proper error handling!
        cb := callbacks[msg header responseTo]
        cb invoke(msg)
        callbacks remove(msg header responseTo)
    }
}
