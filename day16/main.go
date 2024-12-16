package main

import (
	"container/heap"
	"fmt"
	"io"
	"log"
	"math"
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

type Problem struct {
	start Coord
	end   Coord
	grid  map[Coord]rune
}

type Coord struct {
	x, y int
}

type Position struct {
	coord Coord
	dir   Dir
}

type State struct {
	pos    Position
	points int
}

type PQState struct {
	state    State
	priority int // for the PriorityQueue implementation: points + h
	index    int // for the PriorityQueue implementation
}

/** BEGIN this section copied from go container/heap package documentation */

// A PriorityQueue implements heap.Interface and holds Items.
type PriorityQueue []*PQState

func (pq PriorityQueue) Len() int { return len(pq) }

func (pq PriorityQueue) Less(i, j int) bool {
	// We want Pop to give us the lowest points so far
	return pq[i].priority < pq[j].priority
}

func (pq PriorityQueue) Swap(i, j int) {
	pq[i], pq[j] = pq[j], pq[i]
	pq[i].index = i
	pq[j].index = j
}

func (pq *PriorityQueue) Push(x any) {
	n := len(*pq)
	item := x.(*PQState)
	item.index = n
	*pq = append(*pq, item)
}

func (pq *PriorityQueue) Pop() any {
	old := *pq
	n := len(old)
	item := old[n-1]
	old[n-1] = nil  // don't stop the GC from reclaiming the item eventually
	item.index = -1 // for safety
	*pq = old[0 : n-1]
	return item
}

// update modifies the priority and value of an Item in the queue.
func (pq *PriorityQueue) update(state *PQState, value State, priority int) {
	state.state = value
	state.priority = priority
	heap.Fix(pq, state.index)
}

/** END copied from go container/heap package docs */

func parse(s string) Problem {
	lines := strings.Split(strings.TrimSpace(s), "\n")
	grid := make(map[Coord]rune)
	var start, end Coord
	for y, line := range lines {
		line = strings.TrimSpace(line)
		for x, c := range line {
			if c == 'S' {
				start = Coord{x, y}
				grid[Coord{x, y}] = '.'
			} else if c == 'E' {
				end = Coord{x, y}
				grid[Coord{x, y}] = '.'
			} else {
				grid[Coord{x, y}] = c
			}
		}
	}
	return Problem{start, end, grid}
}

// A heuristic function for candidate states. Estimates the remaining distance from the goal.
func h(next State, problem Problem) int {
	nx, ny := next.pos.coord.x, next.pos.coord.y
	gx, gy := problem.end.x, problem.end.y
	dx := nx - gx
	if dx < 0 {
		dx = -dx
	}
	dy := ny - gy
	if dy < 0 {
		dy = -dy
	}
	return dx + dy
}

func deltas(dir Dir) (int, int) {
	if dir == N {
		return 0, -1
	} else if dir == E {
		return 1, 0
	} else if dir == S {
		return 0, 1
	} else {
		return -1, 0
	}
}

func nexts(cur State, problem Problem) []State {
	x, y, dir := cur.pos.coord.x, cur.pos.coord.y, cur.pos.dir
	points := cur.points
	grid := problem.grid

	ns := []State{}
	left, right := dir-1, dir+1
	if left < 0 {
		left += 4
	}
	if right >= 4 {
		right -= 4
	}
	dx, dy := deltas(dir)
	ns = append(ns,
		State{Position{cur.pos.coord, left}, points + 1000},
		State{Position{cur.pos.coord, right}, points + 1000},
	)
	forward := Coord{x + dx, y + dy}
	if grid[forward] != '#' {
		ns = append(ns, State{Position{forward, dir}, points + 1})
	}
	return ns
}

func findAllLocs(cameFrom map[Position][]Position, current Coord) []Coord {
	locsSet := make(map[Coord]bool)
	locsSet[current] = true

	currentset := []Position{}
	for _, dir := range []Dir{N, E, S, W} {
		pos := Position{current, dir}
		_, ok := cameFrom[pos]
		if ok {
			currentset = append(currentset, pos)
		}
	}
	var done bool = false
	for {
		for _, cur := range currentset {
			locsSet[cur.coord] = true
			if _, ok := cameFrom[cur]; !ok {
				done = true
			}
		}
		if done {
			break
		}
		nextset := []Position{}
		for _, cur := range currentset {
			nextset = append(nextset, cameFrom[cur]...)
		}
		currentset = nextset
	}

	locsList := []Coord{}
	for loc := range locsSet {
		locsList = append(locsList, loc)
	}
	return locsList
}

func astar(problem Problem) int {
	start := State{Position{problem.start, E}, 0}
	openSet := make(map[State]bool)
	openSet[start] = true
	openPQ := make(PriorityQueue, 1)
	openPQ[0] = &PQState{
		state:    start,
		priority: h(start, problem),
		index:    0,
	}
	heap.Init(&openPQ)
	gScore := make(map[Position]int)
	for coord := range problem.grid {
		for _, dir := range []Dir{N, E, S, W} {
			gScore[Position{coord, dir}] = math.MaxInt
		}
	}
	gScore[start.pos] = 0

	fScore := make(map[Position]int)
	for coord := range problem.grid {
		for _, dir := range []Dir{N, E, S, W} {
			fScore[Position{coord, dir}] = math.MaxInt
		}
	}
	fScore[start.pos] = h(start, problem)

	for len(openSet) > 0 {
		cur := heap.Pop(&openPQ).(*PQState).state
		delete(openSet, cur)

		if cur.pos.coord == problem.end {
			return cur.points
		}

		for _, n := range nexts(cur, problem) {
			tentative_gScore := gScore[cur.pos] + (n.points - cur.points)
			if tentative_gScore < gScore[n.pos] {
				gScore[n.pos] = tentative_gScore
				fScore[n.pos] = tentative_gScore + h(n, problem)
				if _, ok := openSet[n]; !ok {
					openSet[n] = true
					pqstate := &PQState{state: n, priority: fScore[n.pos]}
					heap.Push(&openPQ, pqstate)
				}
			}
		}
	}
	log.Fatal("Failed to find a path.")
	return -1
}

func part1(input string) string {
	problem := parse(input)
	return fmt.Sprint(astar(problem))
}

func astarallpaths(problem Problem) []Coord {
	start := State{Position{problem.start, E}, 0}
	openSet := make(map[State]bool)
	openSet[start] = true
	openPQ := make(PriorityQueue, 1)
	openPQ[0] = &PQState{
		state:    start,
		priority: h(start, problem),
		index:    0,
	}
	heap.Init(&openPQ)

	cameFrom := make(map[Position][]Position)

	gScore := make(map[Position]int)
	for coord := range problem.grid {
		for _, dir := range []Dir{N, E, S, W} {
			gScore[Position{coord, dir}] = math.MaxInt
		}
	}
	gScore[start.pos] = 0

	fScore := make(map[Position]int)
	for coord := range problem.grid {
		for _, dir := range []Dir{N, E, S, W} {
			fScore[Position{coord, dir}] = math.MaxInt
		}
	}
	fScore[start.pos] = h(start, problem)

	bestpoints := math.MaxInt
	for len(openSet) > 0 {
		cur := heap.Pop(&openPQ).(*PQState).state
		delete(openSet, cur)
		if cur.points > bestpoints {
			return findAllLocs(cameFrom, problem.end)
		}

		if cur.pos.coord == problem.end {
			if cur.points < bestpoints {
				bestpoints = cur.points
			}
		}

		for _, n := range nexts(cur, problem) {
			tentative_gScore := gScore[cur.pos] + (n.points - cur.points)
			if tentative_gScore == gScore[n.pos] {
				cameFrom[n.pos] = append(cameFrom[n.pos], cur.pos)
			} else if tentative_gScore < gScore[n.pos] {
				cameFrom[n.pos] = []Position{cur.pos}
				gScore[n.pos] = tentative_gScore
				fScore[n.pos] = tentative_gScore + h(n, problem)
				if _, ok := openSet[n]; !ok {
					openSet[n] = true
					pqstate := &PQState{state: n, priority: fScore[n.pos]}
					heap.Push(&openPQ, pqstate)
				}
			}
		}
	}
	return []Coord{}
}

func part2(input string) string {
	problem := parse(input)
	allsquares := astarallpaths(problem)
	return fmt.Sprint(len(allsquares))
}

func main() {
	f, err := os.Open("../data/day16.txt")
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
