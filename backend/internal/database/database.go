package database

import (
	"context"
	"fmt"     // Using fmt for errors and potentially URL construction
	"log"
	"time"

	"github.com/jackc/pgx/v5" // Import pgx for QueryExecModeSimpleProtocol
	"github.com/jackc/pgx/v5/pgxpool"
	"village_project/internal/config" // Adjust import path if needed
)

// ConnectDB establishes a connection pool to the PostgreSQL database,
// preferring the DATABASE_URL from config (expected to be Supabase Pooler URL)
// and disabling prepared statement caching.
func ConnectDB(cfg config.Config) (*pgxpool.Pool, error) {
	log.Println("Attempting to connect to database...")

	// --- Get DB URL (prioritize DATABASE_URL from config/env) ---
	var dbURL string
	if cfg.DatabaseURL != "" {
		dbURL = cfg.DatabaseURL // Use directly if provided (expected for pooler)
		log.Printf("Using Database URL from config: %s", dbURL)
	} else {
		// Fallback or error if DATABASE_URL is missing
		// If you still need the *direct* connection logic as a fallback,
		// you could re-add the construction logic from cfg.SupabaseURL and cfg.DBPassword here.
		// However, for EC2 deployment using the pooler, DATABASE_URL should be set.
		return nil, fmt.Errorf("database URL is empty in config (DATABASE_URL env var required)")
	}
	// -------------------------------------------------------------


	// --- Parse Config ---
	dbConfig, err := pgxpool.ParseConfig(dbURL)
	if err != nil {
		log.Printf("Failed to parse database config using URL '%s': %v\n", dbURL, err)
		return nil, err
	}

	// --- Pool Settings ---
	dbConfig.MaxConns = 10
	dbConfig.MinConns = 2
	dbConfig.MaxConnLifetime = time.Hour
	dbConfig.MaxConnIdleTime = time.Minute * 30
	dbConfig.ConnConfig.ConnectTimeout = 10 * time.Second // Connection timeout

	// --- DISABLE PREPARED STATEMENT CACHE ---
	// Required when connecting through PgBouncer (Supabase Pooler)
	// in transaction pooling mode to avoid "prepared statement already exists" errors.
	dbConfig.ConnConfig.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol
	log.Println("Prepared statement cache disabled (Simple Protocol Mode enabled)")
	// ---------------------------------------


	// --- Connect to Pool ---
	log.Println("Connecting to database pool...")
	pool, err := pgxpool.NewWithConfig(context.Background(), dbConfig)
	if err != nil {
		log.Printf("Unable to create connection pool with URL '%s': %v\n", dbURL, err)
		return nil, err
	}

	// --- Ping ---
	pingCtx, cancel := context.WithTimeout(context.Background(), 7*time.Second) // Ping timeout
	defer cancel()
	log.Println("Pinging database...")
	err = pool.Ping(pingCtx)
	if err != nil {
		log.Printf("Database ping failed using URL '%s': %v\n", dbURL, err)
        pool.Close() // Close pool if ping fails
		return nil, err
	}

	log.Println("Database connection established successfully!")
	return pool, nil
}
