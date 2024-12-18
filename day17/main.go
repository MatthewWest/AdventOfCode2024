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

type State struct {
	PC int
	A  int
	B  int
	C  int
}

type Instruction int

const (
	ADV Instruction = 0
	BXL Instruction = 1
	BST Instruction = 2
	JNZ Instruction = 3
	BXC Instruction = 4
	OUT Instruction = 5
	BDV Instruction = 6
	CDV Instruction = 7
)

type Computer struct {
	state        State
	instructions []Instruction
}

func combo(state State, operand int) int {
	if operand >= 0 && operand <= 3 {
		return operand
	}
	if operand == 4 {
		return state.A
	}
	if operand == 5 {
		return state.B
	}
	if operand == 6 {
		return state.C
	}
	log.Fatal("Found an invalid combo operand: ", operand)
	return -1
}

func parse(s string) Computer {
	lines := strings.Split(s, "\n")
	A, err := strconv.Atoi(regexp.MustCompile(`^Register A: (\d+)$`).FindStringSubmatch(lines[0])[1])
	if err != nil {
		log.Fatal(err)
	}
	B, err := strconv.Atoi(regexp.MustCompile(`^Register B: (\d+)$`).FindStringSubmatch(lines[1])[1])
	if err != nil {
		log.Fatal(err)
	}
	C, err := strconv.Atoi(regexp.MustCompile(`^Register C: (\d+)$`).FindStringSubmatch(lines[2])[1])
	if err != nil {
		log.Fatal(err)
	}
	nums := regexp.MustCompile(`^Program: ([0-9,]+)$`).FindStringSubmatch(lines[4])[1]
	instructions := []Instruction{}
	for _, num := range strings.Split(nums, ",") {
		instr, err := strconv.Atoi(num)
		if err != nil {
			log.Fatal(err)
		}
		instructions = append(instructions, Instruction(instr))
	}
	return Computer{State{0, A, B, C}, instructions}
}

func run(computer Computer) string {
	nInstructions := len(computer.instructions)
	outputs := []string{}
	for computer.state.PC < nInstructions {
		op, operand := computer.instructions[computer.state.PC], computer.instructions[computer.state.PC+1]
		if op == ADV {
			computer.state.A = computer.state.A >> combo(computer.state, int(operand))
			computer.state.PC += 2
		} else if op == BXL {
			computer.state.B = computer.state.B ^ int(operand)
			computer.state.PC += 2
		} else if op == BST {
			computer.state.B = combo(computer.state, int(operand)) % 8
			computer.state.PC += 2
		} else if op == JNZ {
			if computer.state.A == 0 {
				computer.state.PC += 2
			} else {
				computer.state.PC = int(operand)
			}
		} else if op == BXC {
			computer.state.B = computer.state.B ^ computer.state.C
			computer.state.PC += 2
		} else if op == OUT {
			computer.state.PC += 2
			outputs = append(outputs, fmt.Sprint(combo(computer.state, int(operand))%8))
		} else if op == BDV {
			computer.state.B = computer.state.A >> combo(computer.state, int(operand))
			computer.state.PC += 2
		} else if op == CDV {
			computer.state.C = computer.state.A >> combo(computer.state, int(operand))
			computer.state.PC += 2
		}
	}
	return strings.Join(outputs, ",")
}

func part1(input string) string {
	computer := parse(input)
	return run(computer)
}

func program(A int) []int {
	outputs := []int{}
	var B, C int
	for i := 0; ; i++ {
		// BST 4
		B = A % 8
		// BXL 1
		B ^= 1
		// CDV 5
		C = A >> B
		// BXC 4
		B ^= C
		// BXL 4
		B ^= 4
		// ADV 3
		A = A >> 3
		// OUT 5
		outputs = append(outputs, B%8)
		// JNZ 0
		if A == 0 {
			break
		}
	}
	return outputs
}

// If bottom 3 digits are:
// x000: C = A >> 1, so output = (1^x)01
// 001: C = A >> 0, so output = 100
// xyz010: C = A >> 3, so output = (1^x)(y^1)(1^z)
// xy011: C = A >> 2, so output = (1^x)(y^1)(0)
// abc..100: C = A >> 5, so output = ab(c^1)
// abc.101: C = A >> 4, so output = abc
// abc....110: C = A >> 7, so output = a(b^1)(c^1)
// abc...111: C = A >> 6, so output = a(b^1)c

func reverseprogram(wantout []Instruction) int {
	// Because each step depends on the previous ones via the bitshift into C,
	// we must keep track of a possible list of As that work at each target.
	As := []int{0}
	for i := len(wantout) - 1; i >= 0; i-- {
		target := wantout[i:]
		var works bool
		var nextAs []int
		for _, A := range As {
			for mod := 0; mod < 8; mod++ {
				candidate := (A << 3) | mod
				res := program(candidate)
				works = true
				for j := 0; j < len(res); j++ {
					if res[j] != int(target[j]) {
						works = false
						break
					}
				}
				if works {
					nextAs = append(nextAs, candidate)
				}
			}
		}
		if len(nextAs) == 0 {
			log.Fatal("Could not find a last 3 bits that works.")
		} else {
			As = nextAs
		}
	}
	min := math.MaxInt
	for i := 0; i < len(As); i++ {
		if As[i] < min {
			min = As[i]
		}
	}
	return min
}

func part2(input string) string {
	computer := parse(input)
	return fmt.Sprint(reverseprogram(computer.instructions))
}

func main() {
	f, err := os.Open("../data/day17.txt")
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
