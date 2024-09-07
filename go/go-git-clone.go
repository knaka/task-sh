package main

import (
	"github.com/go-git/go-git/v5"
	"os"
)

func main() {
	_, err := git.PlainClone(os.Args[2], false, &git.CloneOptions{
		URL:      os.Args[1],
		Progress: os.Stdout,
	})
	if err != nil {
		panic(err)
	}
}
