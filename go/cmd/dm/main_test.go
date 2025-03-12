package main

import (
	"bytes"
	"os"
	"testing"
)

func TestDumpFile(t *testing.T) {
	tmpFile, err := os.CreateTemp("", "file-*.dat")
	if err != nil {
		t.Fatalf("Failed to create temporary file: %v", err)
	}
	defer os.Remove(tmpFile.Name())

	data := []byte{0xFF, 0xFF, 0xC0, 0x01, 0xC0, 0xDE, 0xFF, 0xFF}
	if _, err := tmpFile.Write(data); err != nil {
		t.Fatalf("Failed to write to temporary file: %v", err)
	}
	if err := tmpFile.Close(); err != nil {
		t.Fatalf("Failed to close temporary file: %v", err)
	}

	var buf bytes.Buffer
	dumpFile(tmpFile.Name(), &buf)

	output := buf.String()
	expected := "C0 01 C0 DE"
	if !bytes.Contains([]byte(output), []byte(expected)) {
		t.Errorf("Expected output to contain %q, but got %q", expected, output)
	}
}
