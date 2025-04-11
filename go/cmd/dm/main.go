// dm CLI command to dump a file in hex format
package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"strings"

	"golang.org/x/term"

	//revive:disable:dot-imports
	. "github.com/knaka/go-utils"
	//revive:enable:dot-imports
)

func printable(ch byte) bool {
	return 0x20 <= ch && ch < 0x7F
}

const chNotPrintable = "."

const bytesPerLine = 16

const (
	escSeqRed = "\033[31m"
	escSeqEnd = "\033[0m"
)

const stdinFilename = "-"

// Dump dumps a file in hex format. If the filename is "-", it reads from stdin. If the writer is a terminal, it uses colors.
func dumpFile(filePath string, writer io.Writer) {
	colored := false
	if file, ok := writer.(*os.File); ok {
		colored = term.IsTerminal(int(file.Fd()))
	}
	rawReader := os.Stdin
	if filePath != stdinFilename {
		rawReader = V(os.Open(filePath))
		defer (func() { V0(rawReader.Close()) })()
	}
	reader := bufio.NewReader(rawReader)
	buf := make([]byte, bytesPerLine)
	for addr := 0; ; addr += bytesPerLine {
		pn := PR(reader.Read(buf)).NilIf(io.EOF)
		if pn == nil {
			break
		}
		var hexes []string
		readable := ""
		for i := 0; i < bytesPerLine; i++ {
			if i < *pn {
				hexes = append(hexes, fmt.Sprintf("%02X", buf[i]))
				if printable(buf[i]) {
					readable += string(buf[i])
				} else {
					if colored {
						readable += escSeqRed + chNotPrintable + escSeqEnd
					} else {
						readable += chNotPrintable
					}
				}
			} else {
				hexes = append(hexes, "  ")
				readable += " "
			}
		}
		V0(fmt.Fprintf(writer, "%08X | %s | %s\n",
			addr, strings.Join(hexes, " "), readable))
	}
}

func main() {
	Debugger()
	if len(os.Args) == 1 {
		os.Args = append(os.Args, stdinFilename)
	}
	for _, arg := range os.Args[1:] {
		dumpFile(arg, os.Stdout)
	}
}
