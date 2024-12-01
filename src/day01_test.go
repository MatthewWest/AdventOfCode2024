package main

import (
	"io"
	"log"
	"os"
	"testing"
)

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
				input: `3   4
                        4   3
                        2   5
                        1   3
                        3   9
                        3   3`,
			},
			want: "11",
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
				input: `3   4
                        4   3
                        2   5
                        1   3
                        3   9
                        3   3`,
			},
			want: "31",
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

func BenchmarkPart1(b *testing.B) {
	f, err := os.Open("../data/day01.txt")
	if err != nil {
		log.Fatal(err)
	}
	bytes, err := io.ReadAll(f)
	if err != nil {
		log.Fatal(err)
	}
	s := string(bytes)
	b.ResetTimer()
	part1(s)
}

func BenchmarkPart2(b *testing.B) {
	f, err := os.Open("../data/day01.txt")
	if err != nil {
		log.Fatal(err)
	}
	bytes, err := io.ReadAll(f)
	if err != nil {
		log.Fatal(err)
	}
	s := string(bytes)
	b.ResetTimer()
	part2(s)
}
