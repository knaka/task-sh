/**
 * Obfuscate a string
 */
package main

import (
	"testing"
)

func TestObfuscate32(t *testing.T) {
	type args struct {
		n uint32
	}
	tests := []struct {
		name string
		args args
		want uint32
	}{
		{
			name: "Test case 1",
			args: args{n: 0x12345678},
			want: 0x8C088C00,
		},
		{
			name: "Test case 2",
			args: args{n: 0xFFFFFFFF},
			want: 0x61C32587,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Obfuscate32(tt.args.n); got != tt.want {
				t.Errorf("Decode32() = 0x%08X, want 0x%08X", got, tt.want)
			}
		})
	}
}

func TestDeobfuscate32(t *testing.T) {
	for _, v := range []uint32{0x12345678, 0xFFFFFFFF} {
		obfuscated := Obfuscate32(v)
		deobfuscated := Deobfuscate32(obfuscated)
		if deobfuscated != v {
			t.Errorf("Decode32() = 0x%08X, want 0x%08X", deobfuscated, obfuscated)
		}
	}
}
