package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"strings"
)

type Ordering struct {
	a int
	b int
}

func parse(s string) ([]Ordering, [][]int) {
	s = strings.TrimSpace(s)
	sections := strings.Split(s, "\n\n")
	if len(sections) != 2 {
		log.Fatal("Expected two sections in the input separated by a blank line.")
	}
	var rules []Ordering
	for _, r := range strings.Split(sections[0], "\n") {
		sides := strings.Split(r, "|")
		a, err := strconv.Atoi(sides[0])
		if err != nil {
			log.Fatal(err)
		}
		b, err := strconv.Atoi(sides[1])
		if err != nil {
			log.Fatal(err)
		}
		rules = append(rules, Ordering{a, b})
	}
	var seqs [][]int
	for _, line := range strings.Split(sections[1], "\n") {
		var seq []int
		for _, num := range strings.Split(line, ",") {
			x, err := strconv.Atoi(num)
			if err != nil {
				log.Fatal(err)
			}
			seq = append(seq, x)
		}
		seqs = append(seqs, seq)
	}
	return rules, seqs
}

func validseq(invalidorders map[Ordering]bool, seq []int) bool {
	for i := 0; i < len(seq); i++ {
		for j := 0; j < i; j++ {
			if invalidorders[Ordering{seq[j], seq[i]}] {
				return false
			}
		}
	}
	return true
}

func part1(input string) string {
	rules, seqs := parse(input)
	invalidorders := make(map[Ordering]bool)
	for _, rule := range rules {
		invalidorders[Ordering{rule.b, rule.a}] = true
	}
	var validseqs [][]int
	for _, seq := range seqs {
		if validseq(invalidorders, seq) {
			validseqs = append(validseqs, seq)
		}
	}
	n := 0
	for _, seq := range validseqs {
		l := len(seq)
		if l%2 == 0 {
			log.Fatal("Found a valid sequence with even number of pages.")
		}
		mid := l / 2
		n += seq[mid]
	}
	return fmt.Sprint(n)
}

func removevalue(a []int, x int) []int {
	n := 0
	for _, val := range a {
		if val != x {
			a[n] = val
			n++
		}
	}
	return a[:n]
}

func sort(rules []Ordering, seq []int) []int {
	members := make(map[int]bool)
	for _, x := range seq {
		members[x] = true
	}
	// map from Ordering.a to all Ordering.b values in the seq
	after := make(map[int][]int)
	before := make(map[int][]int)
	for _, rule := range rules {
		if !members[rule.a] || !members[rule.b] {
			continue
		}
		as := before[rule.b]
		if as == nil {
			as = []int{}
		}
		before[rule.b] = append(as, rule.a)
		bs := after[rule.a]
		if bs == nil {
			bs = []int{}
		}
		after[rule.a] = append(bs, rule.b)
	}

	// List to contain sorted elements
	sorted := []int{}
	// Set of nodes with no inbound edges
	S := []int{}
	for _, x := range seq {
		if before[x] == nil {
			S = append(S, x)
		}
	}
	// This is Kahn's Algorithm.
	var node int
	for len(S) > 0 {
		node, S = S[0], S[1:]
		sorted = append(sorted, node)
		for _, m := range after[node] {
			before[m] = removevalue(before[m], node)
			if len(before[m]) == 0 {
				S = append(S, m)
			}
		}
		after[node] = nil
	}
	return sorted
}

func part2(input string) string {
	rules, seqs := parse(input)
	invalidorders := make(map[Ordering]bool)
	for _, rule := range rules {
		invalidorders[Ordering{rule.b, rule.a}] = true
	}
	var invalidseqs [][]int
	for _, seq := range seqs {
		if !validseq(invalidorders, seq) {
			invalidseqs = append(invalidseqs, seq)
		}
	}

	var sortedseqs [][]int
	for _, seq := range invalidseqs {
		sortedseqs = append(sortedseqs, sort(rules, seq))
	}

	n := 0
	for _, seq := range sortedseqs {
		l := len(seq)
		if l%2 == 0 {
			log.Fatal("Middle page is undefined for an even number of pages.")
		}
		mid := l / 2
		n += seq[mid]
	}
	return fmt.Sprint(n)
}

func main() {
	f, err := os.Open("../data/day05.txt")
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
