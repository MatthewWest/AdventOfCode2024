package main

import (
	"testing"
)

var SMALL_TEST_INPUT string = `AAAA
BBCD
BBCC
EEEC`

var TEST_INPUT string = `RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
`

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
			name: "small test input",
			args: args{
				input: SMALL_TEST_INPUT,
			},
			want: "140",
		},
		{
			name: "test input",
			args: args{
				input: TEST_INPUT,
			},
			want: "1930",
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
			name: "small test input",
			args: args{
				input: SMALL_TEST_INPUT,
			},
			want: "80",
		},
		{
			name: "e-shaped input",
			args: args{
				input: `EEEEE
						EXXXX
						EEEEE
						EXXXX
						EEEEE`,
			},
			want: "236",
		},
		{
			name: "ab input",
			args: args{
				input: `AAAAAA
						AAABBA
						AAABBA
						ABBAAA
						ABBAAA
						AAAAAA`,
			},
			want: "368",
		},
		{
			name: "test input",
			args: args{
				input: TEST_INPUT,
			},
			want: "1206",
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
