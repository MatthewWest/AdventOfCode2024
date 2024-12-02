package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

func parse(s string) {
	lines := strings.Split(strings.TrimSpace(s), "\n")
	for _, line := range lines {
		if line == "" {
			continue
		}
	}
}

func part1(input string) string {
	return ""
}

func part2(input string) string {
	return ""
}

func main() {
	f, err := os.Open("../data/day02.txt")
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
