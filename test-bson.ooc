import mongodb/BSON
import io/[BinarySequence, BufferWriter]
import text/Base64
import structs/[Bag, HashBag]

// construct a fun object
list := Bag new()
list add(1 as Int32)
//list add("zwei")
//list add(3.0)

obj := HashBag new()
obj put("someNumber", 1337133713371337 as Int64)
obj put("someString", "Hello World!")
//obj put("someList", list)

// sooper convenient api
buf := Buffer new()
writer := BinarySequenceWriter new(BufferWriter new(buf))
builder := Builder new(writer)

builder writeDocument(obj)

// ohh let's encode it to base64, because we can
Base64 encode(String new(buf)) println()
