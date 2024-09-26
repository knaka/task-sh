package main

import (
	"os"

	. "github.com/knaka/go-utils"
)

func init() {
	task("footask", "Run foo task Y", func() {
		wd := V(os.Getwd())
		println("Foo task in", wd)
	})
}
