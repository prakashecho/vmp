package database

import (
	"context"
	"log"
	"time"

	// "fmt" // Uncomment if using fmt.Sprintf later

	"village_project/internal/config" // Adjust import path if needed

	"github.com/jackc/pgx/v5/pgxpool"
)

// ConnectDB establishes a connection pool to the PostgreSQL database
func ConnectDB(cfg config.Config) (*pgxpool.Pool, error) {
	log.Println("Attempting to connect to database...")
	// log.Printf("Using Database URL: %s\n", cfg.DatabaseURL) // Debug print

	// Parse the config for the connection pool
	dbConfig, err := pgxpool.ParseConfig(cfg.DatabaseURL)
	if err != nil {
		log.Printf("Failed to parse database config: %v\n", err)
		return nil, err
	}

	// Set connection pool settings (optional but recommended)
	dbConfig.MaxConns = 10                      // Max number of connections in the pool
	dbConfig.MinConns = 2                       // Min number of connections to keep open
	dbConfig.MaxConnLifetime = time.Hour        // Max time a connection can be reused
	dbConfig.MaxConnIdleTime = time.Minute * 30 // Max time a connection can be idle

	// Attempt to connect
	pool, err := pgxpool.NewWithConfig(context.Background(), dbConfig)
	if err != nil {
		log.Printf("Unable to create connection pool: %v\n", err)
		return nil, err
	}

	// Ping the database to verify connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err = pool.Ping(ctx)
	if err != nil {
		log.Printf("Database ping failed: %v\n", err)
		pool.Close() // Close the pool if ping fails
		return nil, err
	}

	log.Println("Database connection established successfully!")
	return pool, nil
}
