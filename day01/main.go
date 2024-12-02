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

func parse(s string) ([]int, []int) {
	lines := strings.Split(s, "\n")
	var left []int
	var right []int
	for _, line := range lines {
		if line == "" {
			continue
		}
		parts := strings.Fields(line)
		l, err := strconv.Atoi(parts[0])
		if err != nil {
			log.Fatal(err)
		}
		left = append(left, l)
		r, err := strconv.Atoi(parts[1])
		if err != nil {
			log.Fatal(err)
		}
		right = append(right, r)
	}
	return left, right
}

func part1(input string) string {
	left, right := parse(input)
	slices.Sort(left)
	slices.Sort(right)
	var dist int
	for i, _ := range left {
		d := left[i] - right[i]
		if d < 0 {
			d = -d
		}
		dist += d
	}
	return fmt.Sprint(dist)
}

func part2(input string) string {
	left, right := parse(input)
	similarity := 0
	for _, l := range left {
		sim := 0
		for _, r := range right {
			if l == r {
				sim++
			}
		}
		similarity += sim * l
	}
	return fmt.Sprint(similarity)
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
	s := string(b)
	fmt.Printf("Part 1: %s\n", part1(s))
	fmt.Printf("Part 2: %s\n", part2(s))
}
