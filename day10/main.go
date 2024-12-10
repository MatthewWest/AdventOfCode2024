package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

type Coord struct {
	x int
	y int
}

type Path struct {
	loc   Coord
	score int
}

type Dir int

const (
	N Dir = iota
	E
	S
	W
)

func parse(s string) []string {
	s = strings.TrimSpace(s)
	return strings.Split(s, "\n")
}

func deltas(dir Dir) (int, int, error) {
	if dir == N {
		return 0, -1, nil
	} else if dir == E {
		return 1, 0, nil
	} else if dir == S {
		return 0, 1, nil
	} else if dir == W {
		return -1, 0, nil
	}
	return 0, 0, fmt.Errorf("unknown dir %d", dir)
}

func dfsscore(grid []string, start Coord) (int, error) {
	if grid[start.y][start.x] != '0' {
		return 0, fmt.Errorf("trailhead must start at 0")
	}
	tovisit := []Coord{start}
	waystoreach := make(map[Coord]int)
	waystoreach[start] = 1
	var loc Coord
	for len(tovisit) > 0 {
		loc, tovisit = tovisit[0], tovisit[1:]
		h := int(grid[loc.y][loc.x] - '0')
		for _, dir := range []Dir{N, E, S, W} {
			dx, dy, err := deltas(dir)
			if err != nil {
				return 0, err
			}
			neighbor := Coord{loc.x + dx, loc.y + dy}
			if neighbor.x < 0 || neighbor.x >= len(grid[0]) || neighbor.y < 0 || neighbor.y >= len(grid) {
				continue
			}
			dh := int(grid[neighbor.y][neighbor.x]-'0') - h
			if dh == 1 {
				if waystoreach[neighbor] == 0 {
					tovisit = append(tovisit, neighbor)
					waystoreach[neighbor] = waystoreach[loc]
				} else {
					waystoreach[neighbor] += waystoreach[loc]
				}
			}
		}
	}

	nines := []Coord{}
	for i := 0; i < len(grid); i++ {
		for j := 0; j < len(grid[i]); j++ {
			if grid[i][j] == '9' {
				nines = append(nines, Coord{j, i})
			}
		}
	}
	score := 0
	for _, nine := range nines {
		if waystoreach[nine] > 0 {
			score++
		}
	}
	return score, nil
}

func part1(input string) string {
	grid := parse(input)
	zeros := []Coord{}
	for i := 0; i < len(grid); i++ {
		for j := 0; j < len(grid[i]); j++ {
			if grid[i][j] == '0' {
				zeros = append(zeros, Coord{j, i})
			}
		}
	}
	scores := make(map[Coord]int)
	for _, zero := range zeros {
		score, err := dfsscore(grid, zero)
		if err != nil {
			log.Fatal(err)
		}
		scores[zero] = score
	}

	n := 0
	for _, score := range scores {
		n += score
	}

	return fmt.Sprint(n)
}

func dfsscore2(grid []string, start Coord) (int, error) {
	if grid[start.y][start.x] != '0' {
		return 0, fmt.Errorf("trailhead must start at 0")
	}
	tovisit := []Coord{start}
	waystoreach := make(map[Coord]int)
	waystoreach[start] = 1
	var loc Coord
	for len(tovisit) > 0 {
		loc, tovisit = tovisit[0], tovisit[1:]
		h := int(grid[loc.y][loc.x] - '0')
		for _, dir := range []Dir{N, E, S, W} {
			dx, dy, err := deltas(dir)
			if err != nil {
				return 0, err
			}
			neighbor := Coord{loc.x + dx, loc.y + dy}
			if neighbor.x < 0 || neighbor.x >= len(grid[0]) || neighbor.y < 0 || neighbor.y >= len(grid) {
				continue
			}
			dh := int(grid[neighbor.y][neighbor.x]-'0') - h
			if dh == 1 {
				if waystoreach[neighbor] == 0 {
					tovisit = append(tovisit, neighbor)
					waystoreach[neighbor] = waystoreach[loc]
				} else {
					waystoreach[neighbor] += waystoreach[loc]
				}
			}
		}
	}

	nines := []Coord{}
	for i := 0; i < len(grid); i++ {
		for j := 0; j < len(grid[i]); j++ {
			if grid[i][j] == '9' {
				nines = append(nines, Coord{j, i})
			}
		}
	}
	score := 0
	for _, nine := range nines {
		score += waystoreach[nine]
	}
	return score, nil
}

func part2(input string) string {
	grid := parse(input)
	zeros := []Coord{}
	for i := 0; i < len(grid); i++ {
		for j := 0; j < len(grid[i]); j++ {
			if grid[i][j] == '0' {
				zeros = append(zeros, Coord{j, i})
			}
		}
	}
	scores := make(map[Coord]int)
	for _, zero := range zeros {
		score, err := dfsscore2(grid, zero)
		if err != nil {
			log.Fatal(err)
		}
		scores[zero] = score
	}

	n := 0
	for _, score := range scores {
		n += score
	}

	return fmt.Sprint(n)
}

func main() {
	f, err := os.Open("../data/day10.txt")
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
