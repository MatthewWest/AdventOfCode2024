package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"strings"
)

type Equation struct {
	result int
	nums   []int
}

func parse(s string) []Equation {
	s = strings.TrimSpace(s)
	lines := strings.Split(s, "\n")
	var equations []Equation
	for _, line := range lines {
		parts := strings.Split(strings.TrimSpace(line), ":")
		res, err := strconv.Atoi(parts[0])
		if err != nil {
			log.Fatal(err)
		}
		var nums []int
		for _, n := range strings.Fields(parts[1]) {
			num, err := strconv.Atoi(n)
			if err != nil {
				log.Fatal(err)
			}
			nums = append(nums, num)
		}
		equations = append(equations, Equation{res, nums})
	}
	return equations
}

func canmake(eq Equation) bool {
	if len(eq.nums) == 1 {
		return eq.nums[0] == eq.result
	} else {
		return (canmake(Equation{eq.result, append([]int{eq.nums[0] + eq.nums[1]}, eq.nums[2:]...)}) ||
			canmake(Equation{eq.result, append([]int{eq.nums[0] * eq.nums[1]}, eq.nums[2:]...)}))
	}
}

func part1(input string) string {
	equations := parse(input)
	n := 0
	for _, eq := range equations {
		if canmake(eq) {
			n += eq.result
		}
	}
	return fmt.Sprint(n)
}

func op_append(a int, b int) int {
	res, err := strconv.Atoi(fmt.Sprint(a) + fmt.Sprint(b))
	if err != nil {
		log.Fatal(err)
	}
	return res
}

func canmake2(eq Equation) bool {
	if len(eq.nums) == 1 {
		return eq.nums[0] == eq.result
	} else {
		return (canmake2(Equation{eq.result, append([]int{eq.nums[0] + eq.nums[1]}, eq.nums[2:]...)}) ||
			canmake2(Equation{eq.result, append([]int{eq.nums[0] * eq.nums[1]}, eq.nums[2:]...)}) ||
			canmake2(Equation{eq.result, append([]int{op_append(eq.nums[0], eq.nums[1])}, eq.nums[2:]...)}))
	}
}

func part2(input string) string {
	equations := parse(input)
	n := 0
	for _, eq := range equations {
		if canmake2(eq) {
			n += eq.result
		}
	}
	return fmt.Sprint(n)
}

func main() {
	f, err := os.Open("../data/day07.txt")
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
