package repository

import (
	"context"
	"errors"
	"log"
	"village_project/internal/models" // Adjust import path

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// NewsRepository handles database operations for news items
type NewsRepository struct {
	DB *pgxpool.Pool
}

// NewNewsRepository creates a new instance of NewsRepository
func NewNewsRepository(db *pgxpool.Pool) *NewsRepository {
	return &NewsRepository{DB: db}
}

// ** EXPORT THE ERROR by capitalizing it: E -> E **
// ErrNotFound is a specific error returned when a resource is not found
var ErrNotFound = errors.New("resource not found") // <-- Make sure 'E' is capital

// GetAllPublishedNews fetches all published news items
func (r *NewsRepository) GetAllPublishedNews(ctx context.Context) ([]models.News, error) {
	// ... function body ...
	query := `
		SELECT id, created_at, updated_at, title, content, published_at, status
		FROM public.news
		WHERE status = $1
		ORDER BY published_at DESC;
	`
	rows, err := r.DB.Query(ctx, query, "published")
	if err != nil {
		log.Printf("Error querying published news: %v\n", err)
		return nil, err
	}
	defer rows.Close()

	var newsList []models.News
	for rows.Next() {
		var newsItem models.News
		err := rows.Scan(
			&newsItem.ID,
			&newsItem.CreatedAt,
			&newsItem.UpdatedAt,
			&newsItem.Title,
			&newsItem.Content,
			&newsItem.PublishedAt,
			&newsItem.Status,
		)
		if err != nil {
			log.Printf("Error scanning news row: %v\n", err)
			continue
		}
		newsList = append(newsList, newsItem)
	}
	if err = rows.Err(); err != nil {
		log.Printf("Error iterating news rows: %v\n", err)
		return nil, err
	}
	if newsList == nil {
		return []models.News{}, nil
	}
	return newsList, nil
}

// GetNewsByID fetches a single news item by its UUID
// ** ENSURE METHOD NAME is capitalized and RECEIVER is correct **
func (r *NewsRepository) GetNewsByID(ctx context.Context, id string) (models.News, error) {
	query := `
		SELECT id, created_at, updated_at, title, content, published_at, status
		FROM public.news
		WHERE id = $1;
	`
	var newsItem models.News

	err := r.DB.QueryRow(ctx, query, id).Scan(
		&newsItem.ID,
		&newsItem.CreatedAt,
		&newsItem.UpdatedAt,
		&newsItem.Title,
		&newsItem.Content,
		&newsItem.PublishedAt,
		&newsItem.Status,
	)

	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			log.Printf("No news item found with ID: %s", id)
			// Use the exported error variable (capital E)
			return models.News{}, ErrNotFound
		}
		log.Printf("Error querying news item by ID %s: %v\n", id, err)
		return models.News{}, err
	}

	return newsItem, nil
}
