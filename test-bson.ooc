import mongodb/BSON
import io/[BinarySequence, BufferWriter]
import text/Base64
import structs/[Bag, HashBag]

// construct a fun object
list := Bag new()
list add(1 as Int32)
list add("zwei")
list add(9223372036854775550 as Int64) // should be 0x7ffffffffffffefe, ie. pretty big

obj2 := HashBag new()
obj2 put("this is a STRING!", "Yes it is...")
obj2 put("True", true)
obj2 put("fALSE", false)

obj := HashBag new()
obj put("someNumber", 1337133713371337 as Int64)
obj put("someString", "Hello World!")
obj put("someList", list)
obj put("helpful Values", obj2)

// sooper convenient api
buf := Buffer new()
writer := BinarySequenceWriter new(BufferWriter new(buf))
builder := Builder new(writer)

builder writeDocument(obj)

// ohh let's encode it to base64, because we can
Base64 encode(String new(buf)) println()
