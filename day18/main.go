package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"strings"
)

type Coordinate struct {
	x, y int
}

func parse(s string) []Coordinate {
	lines := strings.Split(strings.TrimSpace(s), "\n")
	coordinates := []Coordinate{}
	for _, line := range lines {
		line = strings.TrimSpace(line)
		parts := strings.Split(line, ",")
		a, err := strconv.Atoi(parts[0])
		if err != nil {
			log.Fatal(err)
		}
		b, err := strconv.Atoi(parts[1])
		if err != nil {
			log.Fatal(err)
		}
		coordinates = append(coordinates, Coordinate{a, b})
	}
	return coordinates
}

func makegrid(coordinates []Coordinate) []string {
	coordsSet := make(map[Coordinate]bool)
	for _, c := range coordinates {
		coordsSet[c] = true
	}
	grid := []string{}
	for y := 0; y < 71; y++ {
		linebuilder := strings.Builder{}
		for x := 0; x < 71; x++ {
			if _, ok := coordsSet[Coordinate{x, y}]; ok {
				linebuilder.WriteString("#")
			} else {
				linebuilder.WriteString(".")
			}
		}
		grid = append(grid, linebuilder.String())
	}
	return grid
}

func pathlength(grid []string, start Coordinate, end Coordinate) int {
	q := []Coordinate{start}
	steps := make(map[Coordinate]int)
	steps[start] = 0
	var cur Coordinate
	for len(q) > 0 {
		cur, q = q[0], q[1:]
		for _, d := range []Coordinate{{-1, 0}, {1, 0}, {0, -1}, {0, 1}} {
			n := Coordinate{cur.x + d.x, cur.y + d.y}
			if _, ok := steps[n]; ok {
				continue
			}
			if n.x < 0 || n.x > 70 || n.y < 0 || n.y > 70 {
				continue
			}
			if grid[n.y][n.x] == '.' {
				q = append(q, n)
				steps[n] = steps[cur] + 1
				if n == end {
					return steps[n]
				}
			}
		}
	}
	return -1
}

func part1(input string) string {
	coordinates := parse(input)
	grid1024 := makegrid(coordinates[:1024])
	return fmt.Sprint(pathlength(grid1024, Coordinate{0, 0}, Coordinate{70, 70}))
}

func part2(input string) string {
	coordinates := parse(input)
	for i := 1024; i < len(coordinates); i++ {
		grid := makegrid(coordinates[:i])
		l := pathlength(grid, Coordinate{0, 0}, Coordinate{70, 70})
		if l < 0 {
			return fmt.Sprintf("%d,%d", coordinates[i-1].x, coordinates[i-1].y)
		}
	}
	return "No solution found."
}

func main() {
	f, err := os.Open("../data/day18.txt")
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
