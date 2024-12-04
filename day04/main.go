package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

func parse(s string) []string {
	var grid []string
	for _, line := range strings.Split(strings.TrimSpace(s), "\n") {
		grid = append(grid, strings.TrimSpace(line))
	}
	return grid
}

type Vector struct {
	X int
	Y int
}

var DIRS []Vector = []Vector{
	{-1, -1},
	{-1, 0},
	{-1, 1},
	{0, -1},
	{0, 1},
	{1, -1},
	{1, 0},
	{1, 1},
}

func has(grid []string, target string, x int, y int, dx int, dy int) bool {
	h, w := len(grid), len(grid[0])
	extremx, extremy := x+dx*(len(target)-1), y+dy*(len(target)-1)
	// Short circuit if the word doesn't fit
	if extremx < 0 || extremx >= w || extremy < 0 || extremy >= h {
		return false
	}
	for i := 0; i < len(target); i++ {
		if grid[y+i*dy][x+i*dx] != target[i] {
			return false
		}
	}
	return true
}

func part1(input string) string {
	grid := parse(input)
	h, w := len(grid), len(grid[0])
	n := 0
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			for _, dir := range DIRS {
				if has(grid, "XMAS", x, y, dir.X, dir.Y) {
					n++
				}
			}
		}
	}
	return fmt.Sprint(n)
}

func has_x_mas(grid []string, x int, y int) bool {
	h, w := len(grid), len(grid[0])
	maxx, maxy := x+2, y+2
	if maxx >= w || maxy >= h {
		return false
	}
	topleft_bottomright :=
		has(grid, "MAS", x, y, 1, 1) ||
			has(grid, "SAM", x, y, 1, 1)
	topright_bottomleft :=
		has(grid, "MAS", x+2, y, -1, 1) || has(grid, "SAM", x+2, y, -1, 1)
	return topleft_bottomright && topright_bottomleft
}

func part2(input string) string {
	grid := parse(input)
	h, w := len(grid), len(grid[0])
	n := 0
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			if has_x_mas(grid, x, y) {
				n++
			}
		}
	}
	return fmt.Sprint(n)
}

func main() {
	f, err := os.Open("../data/day04.txt")
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
