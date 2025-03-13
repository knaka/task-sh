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

// rounds is the number of rounds to obfuscate
const rounds = 2

// hashingConst8 = 2**32 * (-1 + sqrt(5)) / 2
const hashhingConst32 uint32 = 2654435761

// Obfuscate32 obfuscates a 32-bit unsigned integer
func Obfuscate32(n uint32) uint32 {
	left, right := n>>16&0xFFFF, n&0xFFFF
	for i := range rounds {
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

func main() {
	originalExpected := []struct {
		n    uint32
		want uint32
	}{
		{0, 0xE6C4FF0C},
		{1, 0x6075CB6C},
		{2, 0xDA2697CC},
		{3, 0x53D7642C},
		{4, 0xCD883094},
		{5, 0x4739FCF4},
		{6, 0xC0EAC954},
		{7, 0x3A9B95B4},
		{8, 0xB44C621C},
		{9, 0x2DFD2E7C},
		{0xFFFFFFFD, 0x864E788B},
		{0xFFFFFFFE, 0x0C9D44EB},
		{0xFFFFFFFF, 0x92EC114B},
	}
	for _, origExp := range originalExpected {
		obfuscated := Obfuscate32(origExp.n)
		deobfuscated := Deobfuscate32(obfuscated)
		fmt.Fprintf(os.Stderr, "0x%08X -> Obfuscated uint32: 0x%08X -> Deobfuscated uint32: 0x%08X\n",
			origExp.n,
			obfuscated,
			deobfuscated,
		)
		if origExp.want != obfuscated {
			fmt.Fprintf(os.Stderr, "Expected obfuscated value: 0x%08X\n", origExp.want)
		}
	}
	var x uint32 = 0xFFFFFFFF
	var y uint32 = 0xFFFFFFFF
	var z = x * y
	fmt.Fprintf(os.Stderr, "0x%08X * 0x%08X = 0x%08X (%d)\n", x, y, z, z)
}
