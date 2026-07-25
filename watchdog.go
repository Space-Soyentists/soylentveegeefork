package main

import "fmt"
import "log"
import "net/http"
import "os/exec"

func main() {
	http.HandleFunc("/restart", func(w http.ResponseWriter, r *http.Request) {
		cmd := exec.Command("docker", "compose", "restart", "ss13")
		cmd.Run()
		fmt.Fprintf(w, "Restarted!\n")
	})

	log.Fatal(http.ListenAndServe("127.0.0.1:64645", nil))
}
