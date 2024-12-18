package main

import (
	"testing"
)

var STATETEST1 string = `Register A: 0
Register B: 0
Register C: 9

Program: 2,6`

var STATETEST2 string = `Register A: 0
Register B: 29
Register C: 0

Program: 1,7`

var STATETEST3 string = `Register A: 0
Register B: 2024
Register C: 43690

Program: 4,0`

var TEST1 string = `Register A: 10
Register B: 0
Register C: 0

Program: 5,0,5,1,5,4`

var TEST2 string = `Register A: 2024
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0`

var TEST_INPUT string = `Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0`

var QUINE string = `Register A: 117440
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0`

func Test_part1(t *testing.T) {
	type args struct {
		input string
	}
	tests := []struct {
		name string
		args args
		want string
	}{
		{
			name: "state test 1",
			args: args{
				input: STATETEST1,
			},
			want: "",
		},
		{
			name: "state test 2",
			args: args{
				input: STATETEST2,
			},
			want: "",
		},
		{
			name: "state test 3",
			args: args{
				input: STATETEST3,
			},
			want: "",
		},
		{
			name: "small test 1",
			args: args{
				input: TEST1,
			},
			want: "0,1,2",
		},
		{
			name: "small test 2",
			args: args{
				input: TEST2,
			},
			want: "4,2,5,6,7,7,7,7,3,1,0",
		},
		{
			name: "test input",
			args: args{
				input: TEST_INPUT,
			},
			want: "4,6,3,5,6,3,5,2,1,0",
		},
		{
			name: "quine input",
			args: args{
				input: QUINE,
			},
			want: "0,3,5,4,3,0",
		},
		{
			name: "quine real input",
			args: args{
				input: `Register A: 202368258304590
Register B: 0
Register C: 0

Program: 2,4,1,1,7,5,4,4,1,4,0,3,5,5,3,0
`,
			},
			want: "2,4,1,1,7,5,4,4,1,4,0,3,5,5,3,0",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := part1(tt.args.input); got != tt.want {
				t.Errorf("part1() = %v, want %v", got, tt.want)
			}
		})
	}
}

func Test_part2(t *testing.T) {
	type args struct {
		input string
	}
	tests := []struct {
		name string
		args args
		want string
	}{
		{
			name: "working",
			args: args{
				input: `Register A: 35184372088831
Register B: 0
Register C: 0

Program: 2,4,1,1,7,5,4,4,1,4,0,3,5,5,3,0
`,
			},
			want: "",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := part2(tt.args.input); got != tt.want {
				t.Errorf("part2() = %v, want %v", got, tt.want)
			}
		})
	}
}
