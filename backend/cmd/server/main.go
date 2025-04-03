package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings" // Make sure strings is imported
	"syscall"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	// pgxpool is needed here

	// Adjust import paths based on your go.mod module name
	"village_project/internal/config"
	"village_project/internal/database"
	"village_project/internal/handlers"   // <-- IMPORT HANDLERS
	"village_project/internal/repository" // <-- IMPORT REPOSITORY
)

func main() {
	log.Println("Starting server...")

	// --- Load Configuration ---
	cfg, err := config.LoadConfig(".")
	if err != nil {
		log.Fatalf("FATAL: Could not load configuration: %v", err)
	}
	// ... (log config details) ...

	// --- Connect to Database ---
	dbPool, err := database.ConnectDB(cfg)
	if err != nil {
		log.Fatalf("FATAL: Could not connect to database: %v", err)
	}
	defer func() {
		log.Println("Closing database connection pool...")
		dbPool.Close()
	}()
	log.Println("Database pool initialized.")

	// --- Setup Gin Router ---
	router := gin.Default()

	// --- CORS Middleware ---
	corsConfig := cors.DefaultConfig()
	corsConfig.AllowOrigins = strings.Split(cfg.CorsAllowedOrigins, ",")
	corsConfig.AllowCredentials = true
	corsConfig.AllowHeaders = append(corsConfig.AllowHeaders, "Authorization")
	corsConfig.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	router.Use(cors.New(corsConfig))
	log.Println("CORS middleware configured.")

	// --- Instantiate Repositories and Handlers ---
	// Pass the dbPool to the repository constructor
	newsRepo := repository.NewNewsRepository(dbPool)
	// Pass the repository to the handler constructor
	newsHandler := handlers.NewNewsHandler(newsRepo)
	// Instantiate other repos/handlers here later...

	// --- Routes ---
	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		// ... (health check code remains the same) ...
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		defer cancel()
		err := dbPool.Ping(ctx)
		dbStatus := "OK"
		if err != nil {
			dbStatus = "Error"
			log.Printf("Health check DB ping error: %v", err)
			c.JSON(http.StatusInternalServerError, gin.H{"status": "Error", "database": dbStatus})
			return
		}
		c.JSON(http.StatusOK, gin.H{"status": "OK", "database": dbStatus})
	})

	// --- API v1 Routes ---
	apiV1 := router.Group("/api/v1") // Group API routes under /api/v1
	{
		// Register news routes
		apiV1.GET("/news", newsHandler.ListNews) // Map GET /api/v1/news to the ListNews handler
		// Add other news routes here later (e.g., GET /news/:id, POST /news)

		// Register other resource routes here later (events, jobs, etc.)
	}
	log.Println("API routes registered.")

	// --- Start Server ---
	srv := &http.Server{
		Addr:    ":" + cfg.Port,
		Handler: router,
	}

	// Goroutine for graceful shutdown
	go func() {
		log.Printf("Server listening on %s\n", srv.Addr)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("listen: %s\n", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")

	// Context with timeout for shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown:", err)
	}

	log.Println("Server exiting")
}

// Note: We removed the placeholder GetDB function as we are injecting dependencies now.
