package main

import (
	"bufio"
	"fmt"
	"golang.org/x/term"
	"io"
	"os"
	"strings"

	. "github.com/knaka/go-utils"
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

func dumpFile(filePath string, colored bool) {
	var rawReader io.ReadCloser
	if filePath == stdinFilename {
		rawReader = os.Stdin
	} else {
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
		V0(fmt.Fprintf(os.Stdout, "%08X | %s | %s\n",
			addr, strings.Join(hexes, " "), readable))
	}
}

func main() {
	Debugger()
	if len(os.Args) == 1 {
		os.Args = append(os.Args, stdinFilename)
	}
	colored := term.IsTerminal(int(os.Stdout.Fd()))
	for _, arg := range os.Args[1:] {
		dumpFile(arg, colored)
	}
}
