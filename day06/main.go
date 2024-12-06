package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

type Dir int

const (
	N Dir = iota
	E
	S
	W
)

type Coord struct {
	x int
	y int
}

type Pos struct {
	x   int
	y   int
	dir Dir
}

func parse(s string) ([]string, Pos) {
	s = strings.TrimSpace(s)
	lines := strings.Split(s, "\n")
	var pos Pos
	for i := 0; i < len(lines); i++ {
		lines[i] = strings.TrimSpace(lines[i])
		for j := 0; j < len(lines[i]); j++ {
			c := lines[i][j]
			var dir Dir
			if c == '^' {
				dir = N
				lines[i] = strings.Replace(lines[i], "^", ".", 1)
			} else if c == '>' {
				dir = E
				lines[i] = strings.Replace(lines[i], ">", ".", 1)
			} else if c == 'v' {
				dir = S
				lines[i] = strings.Replace(lines[i], "v", ".", 1)
			} else if c == '<' {
				dir = W
				lines[i] = strings.Replace(lines[i], "<", ".", 1)
			} else {
				continue
			}
			pos = Pos{j, i, dir}
		}
	}
	return lines, pos
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

func step(grid []string, pos Pos) (Pos, bool, error) {
	dx, dy, err := deltas(pos.dir)
	if err != nil {
		log.Fatal(err)
	}
	nextx, nexty := pos.x+dx, pos.y+dy
	h, w := len(grid), len(grid[0])
	if nextx < 0 || nextx >= w || nexty < 0 || nexty >= h {
		return pos, true, nil
	} else if grid[nexty][nextx] == '.' {
		return Pos{nextx, nexty, pos.dir}, false, nil
	} else if grid[nexty][nextx] == '#' {
		return Pos{pos.x, pos.y, (pos.dir + 1) % 4}, false, nil
	} else {
		return pos, true, fmt.Errorf("unexpected character %c at coordinates (%d, %d)", grid[nexty][nextx], nextx, nexty)
	}
}

func part1(input string) string {
	grid, pos := parse(input)
	visited := make(map[Coord]bool)
	done := false
	var err error
	for !done {
		visited[Coord{pos.x, pos.y}] = true
		pos, done, err = step(grid, pos)
		if err != nil {
			log.Fatal(err)
		}
	}

	return fmt.Sprint(len(visited))
}

func part2(input string) string {
	grid, pos := parse(input)
	n := 0
	for y := 0; y < len(grid); y++ {
		for x := 0; x < len(grid[y]); x++ {
			if x == pos.x && y == pos.y || grid[y][x] == '#' {
				continue
			}
			blocked := make([]string, len(grid))
			copy(blocked, grid)
			blocked[y] = blocked[y][0:x] + "#" + blocked[y][x+1:]
			visitedpositions := make(map[Pos]bool)
			done := false
			var err error
			p := pos
			for !done {
				if visitedpositions[p] {
					n++
					break
				}
				visitedpositions[p] = true
				p, done, err = step(blocked, p)
				if err != nil {
					log.Fatal(err)
				}
			}
		}
	}
	return fmt.Sprint(n)
}

func main() {
	f, err := os.Open("../data/day06.txt")
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
