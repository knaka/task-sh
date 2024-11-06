package main

import "os"

func main() {
	println("Hello, World4!")
	x := os.Getenv("GOROOT")
	println(x)
}
