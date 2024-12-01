package main

import (
	"fmt"
	"io"
	"log"
	"os"
)

func parse(s string) string {
	return s
}

func part1(input string) string {
	return input
}

func part2(input string) string {
	return input
}

func main() {
	f, err := os.Open("../data/day01.txt")
	if err != nil {
		log.Fatal(err)
	}
	b, err := io.ReadAll(f)
	if err != nil {
		log.Fatal(err)
	}
	s := string(b)
	fmt.Printf("Part 1: %s\n", part1(s))
	fmt.Printf("Part 2: %s\n", part2(s))
}
