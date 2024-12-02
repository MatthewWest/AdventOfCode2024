package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"slices"
	"strconv"
	"strings"
)

func parse(s string) [][]int {
	lines := strings.Split(strings.TrimSpace(s), "\n")
	var input [][]int
	for _, line := range lines {
		if line == "" {
			continue
		}
		parts := strings.Fields(line)
		var linelevel []int
		for _, part := range parts {
			x, err := strconv.Atoi(part)
			if err != nil {
				log.Fatal(err)
			}
			linelevel = append(linelevel, x)
		}
		input = append(input, linelevel)
	}
	return input
}

func safeasc(level []int) bool {
	var prev int
	for i, x := range level {
		if i == 0 {
			prev = x
			continue
		}
		diff := x - prev
		prev = x
		if diff < 1 || diff > 3 {
			return false
		}
	}
	return true
}

func safedesc(level []int) bool {
	var prev int
	for i, x := range level {
		if i == 0 {
			prev = x
			continue
		}
		diff := x - prev
		prev = x
		if diff < -3 || diff > -1 {
			return false
		}
	}
	return true
}

func safe(level []int) bool {
	return safeasc(level) || safedesc(level)
}

func part1(input string) string {
	levels := parse(input)
	n := 0
	for _, level := range levels {
		if safe(level) {
			n++
		}
	}
	return fmt.Sprint(n)
}

func safedampened(level []int) bool {
	n := len(level)
	var dampened []int
	for i := range level {
		if i == 0 {
			dampened = level[1:]
		} else if i == len(level)-1 {
			dampened = level[:n-1]
		} else {
			dampened = slices.Concat(level[:i], level[i+1:])
		}
		log.Println("Dampened to ", dampened)
		if safe(dampened) {
			return true
		}
	}
	return false
}

func part2(input string) string {
	levels := parse(input)
	n := 0
	for _, level := range levels {
		if safedampened(level) {
			n++
		}
	}
	return fmt.Sprint(n)
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
