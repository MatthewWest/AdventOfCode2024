package main

import (
	"testing"
)

var EXTRA_SIMPLE_TEST_INPUT = `..........
...#......
..........
....a.....
..........
.....a....
..........
......#...
..........
..........`

var TEST_INPUT = `............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............`

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
			name: "extra simple test input",
			args: args{
				input: EXTRA_SIMPLE_TEST_INPUT,
			},
			want: "2",
		},
		{
			name: "test input",
			args: args{
				input: TEST_INPUT,
			},
			want: "14",
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
			name: "test input",
			args: args{
				input: TEST_INPUT,
			},
			want: "34",
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
