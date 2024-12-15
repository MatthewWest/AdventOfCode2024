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
	x, y int
}

func toDir(c byte) Dir {
	if c == '<' {
		return W
	} else if c == 'v' {
		return S
	} else if c == '>' {
		return E
	} else if c == '^' {
		return N
	} else {
		log.Fatal("Found a non-direction character ", c)
		return N
	}
}

func parse(s string) (map[Coord]byte, Coord, []Dir) {
	s = strings.TrimSpace(s)
	parts := strings.Split(s, "\n\n")
	grid, instructions := parts[0], parts[1]
	gridlines := strings.Split(grid, "\n")
	contents := make(map[Coord]byte)
	var robot Coord
	for y, line := range gridlines {
		line = strings.TrimSpace(line)
		for x := 0; x < len(line); x++ {
			if line[x] == '@' {
				robot = Coord{x, y}
				contents[Coord{x, y}] = '.'
			} else {
				contents[Coord{x, y}] = line[x]
			}
		}
	}

	moves := []Dir{}
	for i := 0; i < len(instructions); i++ {
		if instructions[i] == '\n' {
			continue
		} else {
			moves = append(moves, toDir(instructions[i]))
		}
	}
	return contents, robot, moves
}

func neighbor(loc Coord, move Dir) Coord {
	if move == N {
		return Coord{loc.x, loc.y - 1}
	} else if move == S {
		return Coord{loc.x, loc.y + 1}
	} else if move == W {
		return Coord{loc.x - 1, loc.y}
	} else {
		return Coord{loc.x + 1, loc.y}
	}
}

func apply(grid map[Coord]byte, robot Coord, move Dir) Coord {
	node := robot
	next := neighbor(node, move)
	if grid[next] == '.' {
		return next
	} else if grid[next] == '#' {
		return robot
	} else {
		place_to_vacate := next
		for grid[next] == 'O' {
			node = next
			next = neighbor(node, move)
		}
		if grid[next] == '#' {
			return robot
		} else if grid[next] == '.' {
			grid[place_to_vacate] = '.'
			grid[next] = 'O'
			return place_to_vacate
		} else {
			log.Fatal("Unexpected condition.")
			return robot
		}
	}
}

func gpscoordsum(grid map[Coord]byte) int {
	total := 0
	for coord, c := range grid {
		if c == 'O' || c == '[' {
			total += coord.x + coord.y*100
		}
	}
	return total
}

func part1(input string) string {
	grid, robot, moves := parse(input)
	for _, m := range moves {
		robot = apply(grid, robot, m)
	}
	return fmt.Sprint(gpscoordsum(grid))
}

func parse2(s string) (map[Coord]byte, Coord, []Dir) {
	s = strings.TrimSpace(s)
	parts := strings.Split(s, "\n\n")
	grid, instructions := parts[0], parts[1]
	gridlines := strings.Split(grid, "\n")
	contents := make(map[Coord]byte)
	var robot Coord
	for y, line := range gridlines {
		line = strings.TrimSpace(line)
		for x := 0; x < len(line); x++ {
			if line[x] == '@' {
				robot = Coord{2 * x, y}
				contents[Coord{2 * x, y}] = '.'
				contents[Coord{2*x + 1, y}] = '.'
			} else {
				if line[x] == 'O' {
					contents[Coord{2 * x, y}] = '['
					contents[Coord{2*x + 1, y}] = ']'
				} else {
					contents[Coord{2 * x, y}] = line[x]
					contents[Coord{2*x + 1, y}] = line[x]
				}
			}
		}
	}

	moves := []Dir{}
	for i := 0; i < len(instructions); i++ {
		if instructions[i] == '\n' {
			continue
		} else {
			moves = append(moves, toDir(instructions[i]))
		}
	}
	return contents, robot, moves
}

func movable(grid map[Coord]byte, space Coord, move Dir, minx int, maxx int, miny int, maxy int) (bool, []Coord) {
	c := grid[space]
	// Base cases
	// Wall, or out of bounds.
	if c == '#' || space.x < 0 || space.x > maxx || space.y < 0 || space.y > maxy {
		return false, []Coord{}
	} else if c == '.' { // free space
		return true, []Coord{}
	}

	// Ensure blocks move together, while making sure that if we're moving east or west, we don't get caught
	// in a stack overflow by recursing on the square we just tried.
	tocheck := []Coord{space}
	tomoveset := make(map[Coord]bool)
	tomoveset[space] = true
	if c == '[' {
		otherside := neighbor(space, E)
		tocheck = append(tocheck, otherside)
		tomoveset[otherside] = true
	} else if c == ']' {
		otherside := neighbor(space, W)
		tocheck = append(tocheck, otherside)
		tomoveset[otherside] = true
	}

	// figure out all the squares which need to be valid to move into in order to move this square.
	next := []Coord{}
	for _, s := range tocheck {
		n := neighbor(s, move)
		if !tomoveset[n] {
			next = append(next, n)
		}
	}

	for _, n := range next {
		moving, movableSquares := movable(
			grid,
			n,
			move,
			minx,
			maxx,
			miny,
			maxy,
		)
		if !moving {
			return false, []Coord{}
		} else {
			for _, s := range movableSquares {
				tomoveset[s] = true
			}
		}
	}
	movable := []Coord{}
	for s := range tomoveset {
		movable = append(movable, s)
	}
	return true, movable
}

func apply2(grid map[Coord]byte, robot Coord, move Dir, minx int, maxx int, miny int, maxy int) (Coord, map[Coord]byte) {
	node := robot
	next := neighbor(node, move)

	if grid[next] == '.' {
		return next, grid
	} else if grid[next] == '#' {
		return robot, grid
	} else {
		nextgrid := make(map[Coord]byte)
		for key, value := range grid {
			nextgrid[key] = value
		}
		moving, tomove := movable(grid, next, move, minx, maxx, miny, maxy)
		if !moving {
			return robot, grid
		}
		moved := make(map[Coord]bool)
		for _, c := range tomove {
			n := neighbor(c, move)
			nextgrid[n] = grid[c]
			moved[n] = true
			if !moved[c] {
				nextgrid[c] = '.'
			}
		}
		return next, nextgrid
	}
}

func part2(input string) string {
	grid, robot, moves := parse2(input)
	var minx, maxx, miny, maxy = 100, 0, 100, 0
	for coord := range grid {
		if coord.x < minx {
			minx = coord.x
		}
		if coord.x > maxx {
			maxx = coord.x
		}
		if coord.y < miny {
			miny = coord.y
		}
		if coord.y > maxy {
			maxy = coord.y
		}
	}
	for _, m := range moves {
		robot, grid = apply2(grid, robot, m, minx, maxx, miny, maxy)
	}
	return fmt.Sprint(gpscoordsum(grid))
}

func main() {
	f, err := os.Open("../data/day15.txt")
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
