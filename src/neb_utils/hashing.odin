package neb_utils

Mix64 :: proc(x: u64) -> u64 {
	x := x
	x ~= x >> 30
	x *= 0xbf58476d1ce4e5b9
	x ~= x >> 27
	x *= 0x94d049bb133111eb
	x ~= x >> 31
	return x
}
