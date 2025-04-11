package obfuscate

import (
	"fmt"
	"os"
	"testing"
)

func TestDeobfuscate32(_ *testing.T) {
	originalExpected := []struct {
		n    uint32
		want uint32
	}{
		{0x00000000, 0xe6c4ff0c},
		{0x00000001, 0x6075cb6c},
		{0x00000002, 0xda2697cc},
		{0x00000003, 0x53d7642c},
		{0x00000004, 0xcd883094},
		{0x00000005, 0x4739fcf4},
		{0x00000006, 0xc0eac954},
		{0x00000007, 0x3a9b95b4},
		{0x00000008, 0xb44c621c},
		{0x00000009, 0x2dfd2e7c},
		{0xfffffffd, 0x864e788b},
		{0xfffffffe, 0x0c9d44eb},
		{0xffffffff, 0x92ec114b},
		{0xdeadbeaf, 0xaa6e1f39},
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
}
