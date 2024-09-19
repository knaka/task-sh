// Piping for poor command line shell (PowerShell).

package main

import (
	. "github.com/knaka/go-utils"
	"os"
	"os/exec"
)

func usage() {
	println("Usage: p [command1] [--] [command2] [--] [command3] ...")
}

func main() {
	if len(os.Args) < 2 {
		usage()
		os.Exit(1)
	}
	var argsList [][]string
	{
		var args []string
		for _, arg := range os.Args[1:] {
			switch arg {
			case "|", ",":
				argsList = append(argsList, args)
				args = nil
			default:
				args = append(args, arg)
			}
		}
		argsList = append(argsList, args)
	}
	var cmds []*exec.Cmd
	for i, args := range argsList {
		cmd := exec.Command(args[0], args[1:]...)
		if i == 0 {
			cmd.Stdin = os.Stdin
		} else {
			cmd.Stdin = V(cmds[i-1].StdoutPipe())
		}
		cmd.Stderr = os.Stderr
		if i == len(argsList)-1 {
			cmd.Stdout = os.Stdout
		}
		cmds = append(cmds, cmd)
	}
	for _, cmd := range cmds {
		V0(cmd.Start())
	}
	for _, cmd := range cmds {
		V0(cmd.Wait())
	}
}
