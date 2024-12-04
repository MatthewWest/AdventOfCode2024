package main

import (
	"testing"
)

var TEST_INPUT string = `MMMSXXMASM
						MSAMXMSMSA
						AMXSXMAAMM
						MSAMASMSMX
						XMASAMXAMM
						XXAMMXXAMA
						SMSMSASXSS
						SAXAMASAAA
						MAMMMXMMMM
						MXMXAXMASX`

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
			name: "test input",
			args: args{
				input: TEST_INPUT,
			},
			want: "18",
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
			want: "9",
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
