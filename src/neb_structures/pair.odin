package structure

Pair :: struct($T1, $T2: typeid) {
	first:  T1,
	second: T2,
}

@(private)
pairMakeEmpty :: proc($T1, $T2: typeid) {
	return Pair(T1, T2){}
}

@(private)
pairMakeCopy :: proc(first: $T1, second: $T2) {
	return Pair(T1, T2){first = first, second = second}
}

@(private)
pairGetFirst :: proc(pair: ^Pair($T1, $T2)) -> T1 {
	return pair.first
}

@(private)
pairGetSecond :: proc(pair: ^Pair($T1, $T2)) -> T2 {
	return pair.second
}
