package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

type Coordinate struct {
	x, y int
}

type Problem struct {
	start Coordinate
	end   Coordinate
	grid  []string
}

type Cheat struct {
	from, dest Coordinate
}

func parse(s string) Problem {
	lines := strings.Split(strings.TrimSpace(s), "\n")
	for i := 0; i < len(lines); i++ {
		lines[i] = strings.TrimSpace(lines[i])
	}
	grid := []string{}
	var start, end Coordinate
	for y := 0; y < len(lines); y++ {
		var row strings.Builder
		for x := 0; x < len(lines[y]); x++ {
			if lines[y][x] == 'S' {
				start = Coordinate{x, y}
				row.WriteByte('.')
			} else if lines[y][x] == 'E' {
				end = Coordinate{x, y}
				row.WriteByte('.')
			} else {
				row.WriteByte(lines[y][x])
			}
		}
		grid = append(grid, row.String())
	}
	return Problem{start, end, grid}
}

func reconstruct(start Coordinate, end Coordinate, from map[Coordinate]Coordinate) []Coordinate {
	cur := end
	revPath := []Coordinate{end}
	for cur != start {
		prev := from[cur]
		revPath = append(revPath, prev)
		cur = prev
	}
	path := []Coordinate{}
	for i := len(revPath) - 1; i >= 0; i-- {
		path = append(path, revPath[i])
	}
	return path
}

func findpath(p Problem) []Coordinate {
	var cur Coordinate
	seen := make(map[Coordinate]bool)
	tovisit := []Coordinate{p.start}
	from := make(map[Coordinate]Coordinate)
	seen[p.start] = true
	for len(tovisit) > 0 {
		cur, tovisit = tovisit[0], tovisit[1:]
		if cur == p.end {
			return reconstruct(p.start, p.end, from)
		}
		for _, delta := range []Coordinate{{-1, 0}, {1, 0}, {0, -1}, {0, 1}} {
			n := Coordinate{cur.x + delta.x, cur.y + delta.y}
			if n.x < 0 && n.x >= len(p.grid[0]) && n.y < 0 && n.y >= len(p.grid) {
				continue
			}
			if p.grid[n.y][n.x] == '.' && !seen[n] {
				seen[n] = true
				tovisit = append(tovisit, n)
				from[n] = cur
			}
		}
	}
	return []Coordinate{}
}

func part1(input string) string {
	problem := parse(input)
	var path []Coordinate = findpath(problem)
	pathIndex := make(map[Coordinate]int)
	for i, c := range path {
		pathIndex[c] = i
	}
	var cheats []Cheat
	for fromIndex, c := range path {
		for _, delta := range []Coordinate{{-2, 0}, {2, 0}, {0, -2}, {0, 2}} {
			// Only consider cheat options which jump over a wall
			midx, midy := c.x+delta.x/2, c.y+delta.y/2
			if problem.grid[midy][midx] != '#' {
				continue
			}
			cheatDest := Coordinate{c.x + delta.x, c.y + delta.y}
			if destIndex, ok := pathIndex[cheatDest]; ok && destIndex > fromIndex {
				cheats = append(cheats, Cheat{c, cheatDest})
			}
		}
	}
	n := 0
	for _, cheat := range cheats {
		cheatOmittedLength := pathIndex[cheat.dest] - pathIndex[cheat.from]
		cheatSaved := cheatOmittedLength - 2
		if cheatSaved >= 100 {
			n++
		}
	}
	return fmt.Sprint(n)
}

func manhattanDistance(a Coordinate, b Coordinate) int {
	dx, dy := a.x-b.x, a.y-b.y
	if dx < 0 {
		dx = -dx
	}
	if dy < 0 {
		dy = -dy
	}
	return dx + dy
}

func part2(input string) string {
	problem := parse(input)
	var path []Coordinate = findpath(problem)
	pathIndex := make(map[Coordinate]int)
	for i, c := range path {
		pathIndex[c] = i
	}
	n := 0
	for i := 0; i < len(path); i++ {
		for j := i + 1; j < len(path); j++ {
			pathDist := j - i
			cheatDist := manhattanDistance(path[i], path[j])
			cheatSaved := pathDist - cheatDist
			if cheatSaved >= 100 && cheatDist <= 20 {
				n++
			}
		}
	}
	return fmt.Sprint(n)
}

func main() {
	f, err := os.Open("../data/day20.txt")
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
