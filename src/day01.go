package day01

import (
	"file"
	"io"
	"log"
)

func parsein(s string) {
	return 
}

func main() {
	file, err := os.Open("data/day01.txt")
	if err != nil {
		log.Fatal(err)
	}
	b, err := io.ReadAll(file)
}