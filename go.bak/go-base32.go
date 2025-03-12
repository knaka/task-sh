package main

import (
	"bytes"
	"encoding/base32"
	"encoding/binary"
)

const encodeLowercase = "abcdefghijkmnoprstuvwxyz02345678" // skips l, 1, q, 9
var endian = binary.LittleEndian
var base32enc = base32.NewEncoding(encodeLowercase).WithPadding(base32.NoPadding)

func intToStrId(x uint32) string {
	buf := new(bytes.Buffer)
	if err := binary.Write(buf, endian, x); err != nil {
		return ""
	}
	return base32enc.EncodeToString(buf.Bytes())
}

func strIdToInt(id string) uint32 {
	decodedBytes, err := base32enc.DecodeString(id)
	if err != nil {
		return 0
	}
	var originalInt uint32
	if err := binary.Read(bytes.NewReader(decodedBytes), endian, &originalInt); err != nil {
		return 0
	}
	return originalInt
}

func main() {
	println(intToStrId(1))
	println(intToStrId(0x7fffffff))
	println(intToStrId(0xffffffff))

	println(strIdToInt(intToStrId(1)))
	println(strIdToInt(intToStrId(0x7fffffff)))
	println(strIdToInt(intToStrId(0xffffffff)))
}
