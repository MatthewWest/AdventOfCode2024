package main

import (
	"fmt"
	"io"
	"log"
	"math"
	"os"
	"regexp"
	"strconv"
	"strings"
)

type Machine struct {
	adx, ady int
	bdx, bdy int
	gx, gy   int
}

func parse(s string) []Machine {
	s = strings.TrimSpace(s)
	mstrings := strings.Split(s, "\n\n")
	machines := []Machine{}
	for _, m := range mstrings {
		lines := strings.Split(m, "\n")
		if len(lines) != 3 {
			log.Fatal("Found a not-matching machine description: ", m, " with ", len(lines), " lines.")
		}
		a_str, b_str, g_str := lines[0], lines[1], lines[2]
		amatch := regexp.MustCompile(`^Button A: X\+(\d+), Y\+(\d+)$`).FindStringSubmatch(a_str)
		adx, err := strconv.Atoi(amatch[1])
		if err != nil {
			log.Fatal(err)
		}
		ady, err := strconv.Atoi(amatch[2])
		if err != nil {
			log.Fatal(err)
		}
		bmatch := regexp.MustCompile(`^Button B: X\+(\d+), Y\+(\d+)$`).FindStringSubmatch(b_str)
		bdx, err := strconv.Atoi(bmatch[1])
		if err != nil {
			log.Fatal(err)
		}
		bdy, err := strconv.Atoi(bmatch[2])
		if err != nil {
			log.Fatal(err)
		}
		gmatch := regexp.MustCompile(`^Prize: X=(\d+), Y=(\d+)$`).FindStringSubmatch(g_str)
		gx, err := strconv.Atoi(gmatch[1])
		if err != nil {
			log.Fatal(err)
		}
		gy, err := strconv.Atoi(gmatch[2])
		if err != nil {
			log.Fatal(err)
		}
		machines = append(machines, Machine{adx, ady, bdx, bdy, gx, gy})
	}
	return machines
}

func part1(input string) string {
	machines := parse(input)
	n := 0
	for _, machine := range machines {
		success, tok := mintokens(machine)
		if success {
			n += tok
		}
	}
	return fmt.Sprint(n)
}

func mintokens(machine Machine) (bool, int) {
	epsilon := 1e-9
	xa, ya := float64(machine.adx), float64(machine.ady)
	xb, yb := float64(machine.bdx), float64(machine.bdy)
	xc, yc := float64(machine.gx), float64(machine.gy)
	b := (xa*yc - ya*xc) / (xa*yb - xb*ya)
	a := (xc - b*xb) / xa
	aInt, rem := math.Modf(a)
	aIsInt := rem <= epsilon
	bInt, rem := math.Modf(b)
	bIsInt := rem <= epsilon
	if aIsInt && bIsInt {
		return true, int(aInt)*3 + int(bInt)
	} else {
		return false, 0
	}
}

func part2(input string) string {
	diff := 10000000000000
	machines := parse(input)
	for i := 0; i < len(machines); i++ {
		machines[i] = Machine{
			machines[i].adx,
			machines[i].ady,
			machines[i].bdx,
			machines[i].bdy,
			machines[i].gx + diff,
			machines[i].gy + diff,
		}
	}
	n := 0
	for _, machine := range machines {
		success, tok := mintokens(machine)
		if success {
			n += tok
		}
	}
	return fmt.Sprint(n)
}

func main() {
	f, err := os.Open("../data/day13.txt")
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
