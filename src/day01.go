package main

import (
	"fmt"
	"io"
	"log"
	"os"
)

func parsein(s string) string {
	return s
}

func main() {
	f, err := os.Open("data/day01.txt")
	if err != nil {
		log.Fatal(err)
	}
	b, err := io.ReadAll(f)
	if err != nil {
		log.Fatal(err)
	}
	input := parsein(string(b))
	fmt.Printf("%s", input)
}
