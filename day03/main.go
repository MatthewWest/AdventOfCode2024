package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"regexp"
	"strconv"
)

func part1(input string) string {
	exp := regexp.MustCompile(`mul\(([0-9]+),([0-9]+)\)`)
	matches := exp.FindAllStringSubmatch(input, -1)
	ans := 0
	for _, match := range matches {
		a, err := strconv.Atoi(match[1])
		if err != nil {
			log.Fatal(err)
		}
		b, err := strconv.Atoi(match[2])
		if err != nil {
			log.Fatal(err)
		}
		ans += a * b
	}
	return fmt.Sprint(ans)
}

func part2(input string) string {
	mul := regexp.MustCompile(`mul\(([0-9]+),([0-9]+)\)`)
	do := regexp.MustCompile(`do\(\)`)
	dont := regexp.MustCompile(`don't\(\)`)
	anymatch := regexp.MustCompile(`(mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\))`)
	matches := anymatch.FindAllStringSubmatch(input, -1)
	enabled := true
	ans := 0
	for _, match := range matches {
		if mul.MatchString(match[0]) {
			if !enabled {
				continue
			}
			a, err := strconv.Atoi(match[2])
			if err != nil {
				log.Fatal(err)
			}
			b, err := strconv.Atoi(match[3])
			if err != nil {
				log.Fatal(err)
			}
			ans += a * b
		} else if do.MatchString(match[0]) {
			enabled = true
		} else if dont.MatchString(match[0]) {
			enabled = false
		} else {
			log.Fatal("Should be unreachable. Reached match ", match[0])
		}
	}
	return fmt.Sprint(ans)
}

func main() {
	f, err := os.Open("../data/day03.txt")
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
