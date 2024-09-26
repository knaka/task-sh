package main

import "os"

var tasks = make(map[string]func())
var taskHelps = make(map[string]string)

func task(name, help string, fn func()) {
	tasks[name] = fn
	taskHelps[name] = help
}

var subcmds = make(map[string]func())
var subcmdHelps = make(map[string]string)

func subcmd(name, help string, fn func()) {
	subcmds[name] = fn
	subcmdHelps[name] = help
}

func main() {
	task("gotask", "Run go task", func() {
		println("Go task")
	})
	subcmd("go:subcmd", "Run go subcommand", func() {
		println("Go subcommand")
	})
	task("tasks", "List tasks", func() {
		for name, help := range taskHelps {
			os.Stdout.WriteString(name + " " + help + "\n")
		}
	})
	task("subcmds", "List subcommands", func() {
		for name, help := range subcmdHelps {
			os.Stdout.WriteString(name + " " + help + "\n")
		}
	})
	if fn, ok := subcmds[os.Args[1]]; ok {
		fn()
		return
	}
	for _, arg := range os.Args[1:] {
		if fn, ok := tasks[arg]; ok {
			fn()
		}
	}
}
