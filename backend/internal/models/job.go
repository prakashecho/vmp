package models

import (
	"time"
)

// Job represents a work listing/job posting
type Job struct {
	ID             string     `json:"id"` // UUID
	CreatedAt      time.Time  `json:"created_at"`
	UpdatedAt      time.Time  `json:"updated_at"`
	Title          string     `json:"title"`             // Job title (e.g., "Paddy Bag Filling")
	Description    string     `json:"description"`       // Detailed description of work
	Location       *string    `json:"location"`          // Optional specific location within/near village
	PaymentDetails *string    `json:"payment_details"`   // How payment works (e.g., "Rs. 500 per day", "Negotiable")
	ContactInfo    string     `json:"contact_info"`      // How interested people should contact poster
	Status         string     `json:"status"`            // e.g., "Open", "Filled", "Expired"
	PostedByUserID *string    `json:"posted_by_user_id"` // UUID of user (nullable for now if no auth)
	ExpiresAt      *time.Time `json:"expires_at"`        // Optional expiry date
}

// CreateJobRequest defines the structure for creating a new job
type CreateJobRequest struct {
	Title          string `json:"title" binding:"required,min=5"`
	Description    string `json:"description" binding:"required,min=10"`
	Location       string `json:"location"`        // Optional, string from frontend
	PaymentDetails string `json:"payment_details"` // Optional, string from frontend
	ContactInfo    string `json:"contact_info" binding:"required,min=5"`
	// We won't include PostedByUserID or Status here; set by backend
}
