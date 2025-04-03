package models

import (
	"time"
)

// News represents a news item from the database
type News struct {
	ID          string    `json:"id"` // Using string for UUID from DB
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
	Title       string    `json:"title"`
	Content     *string   `json:"content"` // Use pointer for nullable text field
	PublishedAt time.Time `json:"published_at"`
	Status      string    `json:"status"`
}
