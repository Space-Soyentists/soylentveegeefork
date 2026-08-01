package main

import (
	"fmt"
	"log"
	"net/http"
	"os/exec"
)

func main() {
	http.HandleFunc("/restart", func(w http.ResponseWriter, r *http.Request) {
		cmd := exec.Command("docker", "compose", "restart", "ss13")
		cmd.Run()
		fmt.Fprintf(w, "Restarted!\n")
	})

	log.Fatal(http.ListenAndServe("0.0.0.0:64645", nil))
}
