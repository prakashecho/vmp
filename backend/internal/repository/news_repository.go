package repository

import (
	"context"
	"log"

	// Adjust import path based on your go.mod module name
	"village_project/internal/models"

	"github.com/jackc/pgx/v5/pgxpool"
)

// NewsRepository handles database operations for news items
type NewsRepository struct {
	// Use a pointer to the pool, good practice
	DB *pgxpool.Pool
}

// NewNewsRepository creates a new instance of NewsRepository
func NewNewsRepository(db *pgxpool.Pool) *NewsRepository {
	return &NewsRepository{DB: db}
}

// GetAllPublishedNews fetches all news items with status 'published', ordered by published date descending
func (r *NewsRepository) GetAllPublishedNews(ctx context.Context) ([]models.News, error) {
	query := `
		SELECT id, created_at, updated_at, title, content, published_at, status
		FROM public.news
		WHERE status = $1
		ORDER BY published_at DESC;
	`
	// It's generally better to have a default LIMIT and handle pagination later
	// For now, we fetch all published news. Add LIMIT $2 if needed.

	rows, err := r.DB.Query(ctx, query, "published") // Filter by status = 'published'
	if err != nil {
		log.Printf("Error querying published news: %v\n", err)
		return nil, err
	}
	defer rows.Close() // Ensure rows are closed

	var newsList []models.News
	for rows.Next() {
		var newsItem models.News
		// Ensure Scan arguments match the SELECT order exactly
		err := rows.Scan(
			&newsItem.ID,
			&newsItem.CreatedAt,
			&newsItem.UpdatedAt,
			&newsItem.Title,
			&newsItem.Content, // Scan directly into pointer for nullable field
			&newsItem.PublishedAt,
			&newsItem.Status,
		)
		if err != nil {
			log.Printf("Error scanning news row: %v\n", err)
			// Decide whether to continue or return error; for now, continue might skip bad rows
			continue // Or return nil, fmt.Errorf("error scanning row: %w", err)
		}
		newsList = append(newsList, newsItem)
	}

	// Check for errors during row iteration
	if err = rows.Err(); err != nil {
		log.Printf("Error iterating news rows: %v\n", err)
		return nil, err
	}

	if newsList == nil {
		// Return an empty slice instead of nil if no news found, often better for JSON marshalling
		return []models.News{}, nil
	}

	return newsList, nil
}

// Add functions here later for GetNewsByID, CreateNews, UpdateNews, DeleteNews etc.
