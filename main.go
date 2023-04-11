package main


import (
	"fmt"
	"io/ioutil"
	"net/http"
	
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Bad request", http.StatusBadRequest)
			return
		}
		defer r.Body.Close()
		fmt.Fprintf(w, "Hello, vous avez envoyé : %s", string(body))
	})

	http.ListenAndServe(":8080", nil)
}
