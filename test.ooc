import io/[Reader, StringReader, BinarySequence, BufferWriter, Writer, FileReader]
import structs/[ArrayList, Bag, HashBag]
import mongodb/[BSON, Message]
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

    msg := Update new()
    msg fullCollectionName = "ooc.test"
    selector := HashBag new()
    selector put("hey", "there from ooc!")

    update := HashBag new()
    update put("cow", "SAYS MOO ALL THE FSCKING TIME")
    
    msg selector = selector
    msg update = update

    msg toWire(seq)

    b := Buffer new()
//    sock receive(b, 100)
    sock close()
}
