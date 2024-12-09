package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"strings"
)

type Node struct {
	free bool
	id   int
}

func parse(s string) []Node {
	s = strings.TrimSpace(s)
	var disk []Node
	id := 0
	for i := 0; i < len(s); i++ {
		if i%2 == 0 {
			filled := int(s[i] - '0')
			for j := 0; j < filled; j++ {
				disk = append(disk, Node{false, id})
			}
			id++
		} else {
			free := int(s[i] - '0')
			for j := 0; j < free; j++ {
				disk = append(disk, Node{true, 0})
			}
		}
	}
	return disk
}

func findnextfree(disk []Node, from int) int {
	for i := from; ; i++ {
		if disk[i].free {
			return i
		}
	}
}

func findprevfull(disk []Node, from int) int {
	for i := from; ; i-- {
		if !disk[i].free {
			return i
		}
	}
}

func compact(disk []Node) []Node {
	freecursor := findnextfree(disk, 0)
	endcursor := findprevfull(disk, len(disk)-1)
	for freecursor < endcursor {
		disk[freecursor] = disk[endcursor]
		disk[endcursor] = Node{true, 0}
		freecursor = findnextfree(disk, freecursor)
		endcursor = findprevfull(disk, endcursor)
	}
	return disk
}

func repr(disk []Node) string {
	var s strings.Builder
	for i := 0; i < len(disk); i++ {
		if disk[i].free {
			s.WriteByte('.')
		} else {
			s.Write([]byte(fmt.Sprint(disk[i].id)))
		}
	}
	return s.String()
}

func checksum(disk []Node) int {
	n := 0
	for i := 0; i < len(disk); i++ {
		if !disk[i].free {
			n += i * disk[i].id
		}
	}
	return n
}

func part1(input string) string {
	disk := parse(input)
	disk = compact(disk)
	return fmt.Sprint(checksum(disk))
}

func findprevblockstart(disk []Node, from int) (int, error) {
	if disk[from].free {
		for i := from; i >= 0; i-- {
			if !disk[i].free {
				from = i
				break
			}
		}
	}
	from_id := disk[from].id
	for i := from; i >= 0; i-- {
		if disk[i].free || disk[i].id != from_id {
			return i + 1, nil
		}
	}
	return 0, fmt.Errorf("did not find a previous block, so we've finished")
}

func blocksize(disk []Node, start int) int {
	n := 0
	startid := disk[start].id
	for i := start; i < len(disk); i++ {
		if disk[i].free || disk[i].id != startid {
			return n
		} else {
			n++
		}
	}
	return n
}

func findblockfree(disk []Node, n int, before int) (int, error) {
	freecount := 0
	freestart := 0
	for i := 0; i < before; i++ {
		if disk[i].free {
			if freecount == 0 {
				freestart = i
			}
			freecount++
			if freecount >= n {
				return freestart, nil
			}
		} else {
			freecount = 0
			freestart = 0
		}
	}
	return 0, fmt.Errorf("did not find a free block")
}

func compactnofragmentation(disk []Node) []Node {
	processed_ids := make(map[int]bool)
	for i := len(disk) - 1; i >= 0; i-- {
		// log.Print(repr(disk))
		i, err := findprevblockstart(disk, i)
		if err != nil {
			break
		}
		blocklen := blocksize(disk, i)
		id := disk[i].id
		if processed_ids[id] {
			continue
		}
		to, err := findblockfree(disk, blocklen, i)
		if err != nil {
			continue
		}
		for j := 0; j < blocklen; j++ {
			disk[to+j] = disk[i+j]
			disk[i+j] = Node{free: true, id: 0}
		}
		processed_ids[id] = true
	}

	return disk
}

func part2(input string) string {
	disk := parse(input)
	disk = compactnofragmentation(disk)
	return fmt.Sprint(checksum(disk))
}

func main() {
	f, err := os.Open("../data/day09.txt")
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
