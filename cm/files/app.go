package main
import (
        "fmt"
        "net/http"
        "os"
)
func handler(w http.ResponseWriter, r *http.Request) {
        h, _ := os.Hostname()
        fmt.Fprintf(w, "Hi there, I'm served from %s!", h)
}
func main() {
        fmt.Println("Started.")
        http.HandleFunc("/", handler)
        http.ListenAndServe(":8484", nil)
        fmt.Println("Stopped.")
}