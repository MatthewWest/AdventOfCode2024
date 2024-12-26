package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

func parse(s string) ([]string, []string) {
	parts := strings.Split(strings.TrimSpace(s), "\n\n")
	towelblock, patternblock := parts[0], parts[1]
	towels := strings.Split(towelblock, ",")
	for i := 0; i < len(towels); i++ {
		towels[i] = strings.TrimSpace(towels[i])
	}
	patterns := strings.Split(patternblock, "\n")
	for i := 0; i < len(patterns); i++ {
		patterns[i] = strings.TrimSpace(patterns[i])
	}
	return towels, patterns
}

func ispossible(towels []string, pattern string, memotable map[string]bool) bool {
	if pattern == "" {
		return true
	}
	for _, t := range towels {
		if strings.HasPrefix(pattern, t) {
			rest := pattern[len(t):]
			result, inmemotable := memotable[rest]
			if !inmemotable {
				result = ispossible(towels, rest, memotable)
				memotable[rest] = result
			}
			if result {
				return result
			}
		}
	}
	return false
}

func possibleways(towels []string, pattern string) int {
	nWays := []int{}
	for i := 0; i < len(pattern); i++ {
		nWays = append(nWays, 0)
		for _, t := range towels {
			precedingStart := i - len(t) + 1
			if precedingStart < 0 {
				continue
			}
			preceding := pattern[precedingStart:]

			if strings.HasPrefix(preceding, t) {
				var nPreceding int
				if precedingStart > 0 {
					nPreceding = nWays[precedingStart-1]
				} else {
					nPreceding = 1
				}
				nWays[i] += nPreceding
			}
		}
	}
	return nWays[len(nWays)-1]
}

func part1(input string) string {
	towels, patterns := parse(input)
	n := 0
	for _, p := range patterns {
		possible := ispossible(towels, p, make(map[string]bool))
		if possible {
			n++
		}
	}
	return fmt.Sprint(n)
}

func part2(input string) string {
	towels, patterns := parse(input)
	n := 0
	for _, p := range patterns {
		n += possibleways(towels, p)
	}
	return fmt.Sprint(n)
}

func main() {
	f, err := os.Open("../data/day19.txt")
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
