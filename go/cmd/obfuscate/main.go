package main

import (
	"app/obfuscate"
	"fmt"
	"os"
)

// hashingConst8 = 2**8 * (-1 + sqrt(5)) / 2
const hashingConst8 = 158

// rounds is the number of rounds to obfuscate
const rounds = 2

// hashingConst8 = 2**32 * (-1 + sqrt(5)) / 2
const hashhingConst32 uint32 = 2654435761

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
		obfuscated := obfuscate.Obfuscate32(origExp.n)
		deobfuscated := obfuscate.Deobfuscate32(obfuscated)
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
