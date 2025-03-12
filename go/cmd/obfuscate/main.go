/**
 * Obfuscate a string
 */
package main

import (
	"fmt"
	"os"
)

// hashingConst8 = 2**8 * (-1 + sqrt(5)) / 2
const hashingConst8 = 158

// rounds is the number of rounds to obfuscate
const rounds = 2

// Obfuscate obfuscates a byte array
func Obfuscate(array []byte) []byte {
	for i := range array {
		left := array[i] >> 4 & 0x0F
		right := array[i] & 0x0F
		for j := range rounds {
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

// hashingConst8 = 2**32 * (-1 + sqrt(5)) / 2
const hashhingConst32 uint32 = 2654435761

// Obfuscate32 obfuscates a 32-bit unsigned integer
func Obfuscate32(n uint32) uint32 {
	left, right := n>>16&0xFFFF, n&0xFFFF
	for i := range rounds {
		left, right = right, left^(right*hashhingConst32+uint32(i))&0xFFFF
	}
	return left<<16 | right
}

// Deobfuscate32 deobfuscates a 32-bit unsigned integer
func Deobfuscate32(n uint32) uint32 {
	left, right := n>>16&0xFFFF, n&0xFFFF
	for i := rounds - 1; i >= 0; i-- {
		left, right = right^(left*hashhingConst32+uint32(i))&0xFFFF, left
	}
	return left<<16 | right
}

func main() {
	for i := range 10 {
		fmt.Fprintf(os.Stderr, "0x%08X -> Obfuscated uint32: 0x%08X\n",
			i,
			Obfuscate32(uint32(i)),
		)
	}
}
