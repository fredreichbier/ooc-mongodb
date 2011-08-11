import io/[Reader, StringReader, BinarySequence, BufferWriter, Writer]
import structs/[Bag,HashBag]
import mongodb/BSON

/*s :="\x16\x00\x00\x00\x02hello\x00\x06\x00\x00\x00world\x00\x00" 
r := StringReader new(s)
b := BinarySequenceReader new(r)

bson := Parser new(b)
bson readAll()
bson document get("hello", String) as String println()*/

b := HashBag new()
b put("hello", 123.456 as Double)
b put("yo", true)
r := Regex new("hey[a-z]+", "f")
b put("regx", r)

b2 := Bag new()
b2 add("hai")
b2 add(false)
b2 add(b)

//b put("arr", b2)

s := Buffer new(100)
w := BufferWriter new(s)
writeArray(w, b2)

String new(s) println()
