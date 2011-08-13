import io/[Reader, StringReader, BinarySequence, BufferWriter, Writer, FileReader]
import structs/[ArrayList, Bag, HashBag]
import mongodb/BSON


main: func (args: ArrayList<String>) {
    reader := FileReader new(args[1])
    seq := BinarySequenceReader new(reader)

    bson := Parser new(seq)
    bson readAll()
    
    buffer := Buffer new(100)
    writer := BufferWriter new(buffer)
    writeDocument(writer, bson document)
    String new(buffer) println()
}
