import net/[Address, StreamSocket]
import io/BinarySequence

import Message

Server: class {
    addr: SocketAddress

    socket: StreamSocket
    reader: StreamSocketReader
    writer: StreamSocketWriter

    binaryWriter: BinarySequenceWriter

    init: func (=addr) {
        socket = StreamSocket new(addr)
        reader = socket reader()
        writer = socket writer()
        binaryWriter = BinarySequenceWriter new(writer)
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
}
