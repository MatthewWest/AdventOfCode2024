package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"math"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type Robot struct {
	x, y   int
	vx, vy int
}

type Coord struct {
	x, y int
}

func parse(s string) []Robot {
	s = strings.TrimSpace(s)
	lines := strings.Split(s, "\n")
	robots := []Robot{}
	for _, line := range lines {
		robotregexp := regexp.MustCompile(`^p=(\d+),(\d+) v=(-?\d+),(-?\d+)$`)
		if !robotregexp.MatchString(line) {
			log.Fatal("Found line not matching a robot format: ", line)
		}
		matches := robotregexp.FindStringSubmatch(line)
		x, err := strconv.Atoi(matches[1])
		if err != nil {
			log.Fatal(err)
		}
		y, err := strconv.Atoi(matches[2])
		if err != nil {
			log.Fatal(err)
		}
		vx, err := strconv.Atoi(matches[3])
		if err != nil {
			log.Fatal(err)
		}
		vy, err := strconv.Atoi(matches[4])
		if err != nil {
			log.Fatal(err)
		}
		robots = append(robots, Robot{x, y, vx, vy})
	}
	return robots
}

func step(robot Robot, maxx int, maxy int) Robot {
	x, y, vx, vy := robot.x, robot.y, robot.vx, robot.vy
	nextx, nexty := x+vx, y+vy
	if nextx < 0 {
		nextx += maxx
	}
	if nexty < 0 {
		nexty += maxy
	}
	nextx %= maxx
	nexty %= maxy
	return Robot{nextx, nexty, vx, vy}
}

func part1(input string, maxx int, maxy int) string {
	robots := parse(input)
	for i := 0; i < 100; i++ {
		for j, robot := range robots {
			robots[j] = step(robot, maxx, maxy)
		}
	}
	NW, NE, SW, SE := 0, 0, 0, 0
	midx, midy := maxx/2, maxy/2
	for _, robot := range robots {
		if robot.x < midx && robot.y < midy {
			NW++
		} else if robot.x > midx && robot.y < midy {
			NE++
		} else if robot.x < midx && robot.y > midy {
			SW++
		} else if robot.x > midx && robot.y > midy {
			SE++
		} else {
			// These robots are exactly on a midline, so they are not counted.
		}
	}
	return fmt.Sprint(NW * NE * SW * SE)
}

func printrobots(robots []Robot, maxx int, maxy int) {
	robotlocs := make(map[Coord]bool)
	for _, r := range robots {
		robotlocs[Coord{r.x, r.y}] = true
	}
	for y := 0; y < maxy; y++ {
		for x := 0; x < maxx; x++ {
			if robotlocs[Coord{x, y}] {
				fmt.Print("#")
			} else {
				fmt.Print(" ")
			}
		}
		fmt.Print("\n")
	}
}

func totaldist(robots []Robot) float64 {
	total := 0.0
	for i := 0; i < len(robots)-1; i++ {
		for j := i; j < len(robots); j++ {
			total += math.Sqrt(math.Pow(float64(robots[i].x-robots[j].x), 2) + math.Pow(float64(robots[i].y-robots[j].y), 2))
		}
	}
	return total
}

func part2(input string, maxx int, maxy int) string {
	robots := parse(input)
	mindist := math.Inf(1)
	scanner := bufio.NewScanner(os.Stdin)
	for t := 0; ; t++ {
		dist := totaldist(robots)
		if dist < mindist {
			printrobots(robots, maxx, maxy)
			mindist = dist
			fmt.Print("Has the easter egg been reached? (Y/N)")
			scanner.Scan()
			ans := scanner.Text()
			if ans == "Y" {
				return fmt.Sprint(t)
			}
		}
		for j, robot := range robots {
			robots[j] = step(robot, maxx, maxy)
		}
	}
}

func main() {
	f, err := os.Open("../data/day14.txt")
	if err != nil {
		log.Fatal(err)
	}
	b, err := io.ReadAll(f)
	if err != nil {
		log.Fatal(err)
	}
	s := string(b)
	fmt.Printf("Part 1: %s\n", part1(s, 101, 103))
	fmt.Printf("Part 2: %s\n", part2(s, 101, 103))
}
