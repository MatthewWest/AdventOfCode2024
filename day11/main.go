package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"strings"
)

func parse(s string) []string {
	s = strings.TrimSpace(s)
	return strings.Fields(s)
}

func truncateleadingzeros(s string) string {
	if len(s) > 1 {
		if s[0] == '0' {
			return truncateleadingzeros(s[1:])
		}
		return s
	} else {
		return s
	}
}

func step(s string) []string {
	if s == "0" {
		return []string{"1"}
	} else if len(s)%2 == 0 {
		halflen := len(s) / 2
		a, b := truncateleadingzeros(s[0:halflen]), truncateleadingzeros(s[halflen:])
		return []string{a, b}
	} else {
		n, err := strconv.Atoi(s)
		if err != nil {
			log.Fatal(err)
		}
		return []string{fmt.Sprint(n * 2024)}
	}
}

func part1(input string) string {
	stones := parse(input)
	for i := 0; i < 25; i++ {
		next := []string{}
		for _, stone := range stones {
			next = append(next, step(stone)...)
		}
		stones = next
	}
	return fmt.Sprint(len(stones))
}

func part2(input string) string {
	stones := parse(input)
	stonecounts := make(map[string]int)
	successorstable := make(map[string][]string)
	for _, stone := range stones {
		if stonecounts[stone] > 0 {
			stonecounts[stone]++
		} else {
			stonecounts[stone] = 1
		}
	}
	for i := 0; i < 75; i++ {
		nextcounts := make(map[string]int)
		for stone, count := range stonecounts {
			var successors []string = successorstable[stone]
			if successorstable[stone] == nil {
				successors = step(stone)
				successorstable[stone] = successors
			}
			for _, successor := range successors {
				if nextcounts[successor] > 0 {
					nextcounts[successor] += count
				} else {
					nextcounts[successor] = count
				}
			}
		}
		stonecounts = nextcounts
	}
	n := 0
	for _, count := range stonecounts {
		n += count
	}
	return fmt.Sprint(n)
}

func main() {
	f, err := os.Open("../data/day11.txt")
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
