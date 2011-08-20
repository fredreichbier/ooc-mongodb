import io/[Reader, StringReader, BinarySequence, BufferWriter, Writer, FileReader]
import structs/[ArrayList, Bag, HashBag]
import mongodb/[BSON, Message]
import io/FileWriter
import net/[Address, StreamSocket]

main: func (args: ArrayList<String>) {
    ip := IP4Address new("localhost")
    addr := SocketAddress new(ip, 27017)

    sock := StreamSocket new(addr)
    writer := sock writer()
    seq := BinarySequenceWriter new(writer)
    sock connect()

//    msg := Insert new()
//    msg fullCollectionName = "ooc.test"
//    doc := HashBag new()
//    doc put("hey", "there from ooc!")

//    msg addDocument(doc)

    msg := Query new()
    msg fullCollectionName = "ooc.test"
    msg query = HashBag new() 

    msg toWire(seq)

    b := Buffer new()
    reader := sock reader()
    seq2 := BinarySequenceReader new(reader)
    msg2 := Reply new()
    msg2 fromWire(seq2)

    w := FileWriter new(stdout)
    for(doc in msg2 documents) {
        writeDocument(w, doc)
    }

    sock close()
}
