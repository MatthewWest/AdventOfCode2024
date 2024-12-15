package main

import "testing"

var TEST_INPUT string = `p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3`

func Test_part1(t *testing.T) {
	type args struct {
		input string
		maxx  int
		maxy  int
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
				maxx:  11,
				maxy:  7,
			},
			want: "12",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := part1(tt.args.input, tt.args.maxx, tt.args.maxy); got != tt.want {
				t.Errorf("part1() = %v, want %v", got, tt.want)
			}
		})
	}
}
