package main

import (
	tasks2 "app/tasks"
	"os"

	. "github.com/knaka/go-utils"
)

func init() {
	task("footask", "Run foo task Y", func() {
		wd := V(os.Getwd())
		println("Foo task in", wd)
		tasks2.Fuga()
	})
}
