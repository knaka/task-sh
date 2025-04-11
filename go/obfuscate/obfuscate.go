// Package obfuscate provides functions to obfuscate and deobfuscate byte arrays and 32-bit unsigned integers.
package obfuscate

// hashingConst8 = 2**8 * (-1 + sqrt(5)) / 2
const hashingConst8 = 158

// rounds is the number of rounds to obfuscate
const rounds = 2

// hashingConst8 = 2**32 * (-1 + sqrt(5)) / 2
const hashhingConst32 uint32 = 2654435761

// Obfuscate obfuscates a byte array
func Obfuscate(array []byte) []byte {
	for i := range array {
		left := array[i] >> 4 & 0x0F
		right := array[i] & 0x0F
		for j := 0; j < rounds; j++ {
			left, right = right, left^(right*hashingConst8+uint8(j))&0x0F
		}
		array[i] = left<<4 | right
	}
	return array
}

// Deobfuscate deobfuscates a byte array
func Deobfuscate(array []byte) []byte {
	for i := range array {
		array[i] ^= uint8(hashingConst8 * (i + 1) % 256)
	}
	return array
}

// Obfuscate32 obfuscates a 32-bit unsigned integer
func Obfuscate32(n uint32) uint32 {
	left, right := n>>16&0xFFFF, n&0xFFFF
	for i := 0; i < rounds; i++ {
		left, right = right, left^((right+uint32(i+1)<<2)*hashhingConst32)&0xFFFF
	}
	return left<<16 | right
}

// Deobfuscate32 deobfuscates a 32-bit unsigned integer
func Deobfuscate32(n uint32) uint32 {
	left, right := n>>16&0xFFFF, n&0xFFFF
	for i := rounds - 1; i >= 0; i-- {
		left, right = right^((left+uint32(i+1)<<2)*hashhingConst32)&0xFFFF, left
	}
	return left<<16 | right
}
