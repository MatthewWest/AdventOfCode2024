package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

type Dims struct {
	w int
	h int
}

type Coord struct {
	x int
	y int
}

func parse(s string) (Dims, map[byte][]Coord) {
	s = strings.TrimSpace(s)
	lines := strings.Split(s, "\n")
	antennas := make(map[byte][]Coord)
	for i := 0; i < len(lines); i++ {
		lines[i] = strings.TrimSpace(lines[i])
		for j := 0; j < len(lines[i]); j++ {
			c := lines[i][j]
			if c == '.' {
				continue
			}
			antennas[c] = append(antennas[c], Coord{j, i})
		}
	}
	return Dims{w: len(lines[0]), h: len(lines)}, antennas
}

func part1(input string) string {
	dims, antennas := parse(input)
	has_antinode := make(map[Coord]bool)
	for _, locs := range antennas {
		for i := 0; i < len(locs)-1; i++ {
			for j := i + 1; j < len(locs); j++ {
				dx, dy := locs[i].x-locs[j].x, locs[i].y-locs[j].y
				n1x, n1y := locs[i].x+dx, locs[i].y+dy
				n2x, n2y := locs[j].x-dx, locs[j].y-dy
				if n1x >= 0 && n1x < dims.w && n1y >= 0 && n1y < dims.h {
					has_antinode[Coord{n1x, n1y}] = true
				}
				if n2x >= 0 && n2x < dims.w && n2y >= 0 && n2y < dims.h {
					has_antinode[Coord{n2x, n2y}] = true
				}
			}
		}
	}
	return fmt.Sprint(len(has_antinode))
}

func part2(input string) string {
	dims, antennas := parse(input)
	has_antinode := make(map[Coord]bool)
	for _, locs := range antennas {
		for i := 0; i < len(locs)-1; i++ {
			for j := i + 1; j < len(locs); j++ {
				dx, dy := locs[i].x-locs[j].x, locs[i].y-locs[j].y
				for k := 0; ; k++ {
					nx, ny := locs[i].x+k*dx, locs[i].y+k*dy
					if nx >= 0 && nx < dims.w && ny >= 0 && ny < dims.h {
						has_antinode[Coord{nx, ny}] = true
					} else {
						break
					}
				}
				for k := -1; ; k-- {
					nx, ny := locs[i].x+k*dx, locs[i].y+k*dy
					if nx >= 0 && nx < dims.w && ny >= 0 && ny < dims.h {
						has_antinode[Coord{nx, ny}] = true
					} else {
						break
					}
				}
			}
		}
	}

	return fmt.Sprint(len(has_antinode))
}

func main() {
	f, err := os.Open("../data/day08.txt")
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
