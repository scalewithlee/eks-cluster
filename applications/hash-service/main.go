package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"
)

// Storage for our messages, key=hash value=message
type MessageStore struct {
	data  map[string]string
	mutex sync.RWMutex
}

// Initialize a new message store
func NewMessageStore() *MessageStore {
	return &MessageStore{
		data: make(map[string]string),
	}
}

// Store a message and return its SHA256 hash
func (ms *MessageStore) StoreMessage(message string) string {
	hash := calculateSHA256(message)

	ms.mutex.Lock()
	ms.data[hash] = message
	ms.mutex.Unlock()

	return hash
}

// Retrieve a message by its SHA256 hash
func (ms *MessageStore) GetMessage(hash string) (string, bool) {
	ms.mutex.RLock()
	message, exists := ms.data[hash]
	ms.mutex.RUnlock()

	return message, exists
}

// Calculate a SHA256 hash for a string
func calculateSHA256(message string) string {
	hash := sha256.New()
	hash.Write([]byte(message))
	return hex.EncodeToString(hash.Sum(nil))
}

// Request and response struct definitions
type StoreMessageRequest struct {
	Message string `json:"message"`
}

type StoreMessageResponse struct {
	Hash string `json:"hash"`
}

type GetMessageRequest struct {
	Hash string `json:"hash"`
}

type GetMessageResponse struct {
	Message string `json:"message"`
	Found   bool   `json:"found"`
}

func main() {
	// Get port from environment, or use 8080
	port := os.Getenv("HASH_SERVICE_PORT")
	if port == "" {
		port = "8080"
	}

	// Initialize the message store
	store := NewMessageStore()

	// Define HTTP endpoints
	http.HandleFunc("/store", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		var request StoreMessageRequest
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		if request.Message == "" {
			http.Error(w, "Message cannot be empty", http.StatusBadRequest)
			return
		}

		hash := store.StoreMessage(request.Message)

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(StoreMessageResponse{Hash: hash})
	})

	http.HandleFunc("/get", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		var request GetMessageRequest
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		if request.Hash == "" {
			http.Error(w, "Hash cannot be empty", http.StatusBadRequest)
			return
		}

		message, found := store.GetMessage(request.Hash)

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(GetMessageResponse{
			Message: message,
			Found:   found,
		})
	})

	// Health check endpoint
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "healthy as can be")
	})

	// Fire it up!
	log.Printf("Server starting on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
