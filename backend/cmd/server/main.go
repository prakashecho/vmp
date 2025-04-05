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

	// Ensure pgxpool is imported if needed directly (like in health check)
	// Adjust import paths based on your go.mod module name
	"village_project/internal/config"
	"village_project/internal/database"
	"village_project/internal/handlers"   // Import handlers
	"village_project/internal/repository" // Import repository
)

func main() {
	log.Println("Starting server...")

	// --- Load Configuration ---
	cfg, err := config.LoadConfig(".")
	if err != nil {
		log.Fatalf("FATAL: Could not load configuration: %v", err)
	}
	log.Printf("Server will run on port: %s", cfg.Port)
	log.Printf("CORS Origins: %s", cfg.CorsAllowedOrigins)
	// Add other config logs if needed

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
	// Consider setting ReleaseMode based on GIN_MODE env var
	if cfg.GinMode == "release" {
		gin.SetMode(gin.ReleaseMode)
		log.Println("Running in release mode")
	} else {
		log.Println("Running in debug mode")
	}
	router := gin.Default() // Includes logger and recovery middleware

	// --- CORS Middleware ---
	corsConfig := cors.DefaultConfig()
	corsConfig.AllowOrigins = strings.Split(cfg.CorsAllowedOrigins, ",")
	corsConfig.AllowCredentials = true
	corsConfig.AllowHeaders = append(corsConfig.AllowHeaders, "Authorization", "Content-Type") // Ensure Content-Type is allowed for POST
	corsConfig.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	router.Use(cors.New(corsConfig))
	log.Println("CORS middleware configured.")

	// --- Instantiate Repositories and Handlers ---
	// Pass the dbPool to the repository constructor
	newsRepo := repository.NewNewsRepository(dbPool)
	// Pass the repository to the handler constructor
	newsHandler := handlers.NewNewsHandler(newsRepo)

	// ** Instantiate Job Repository and Handler **
	jobRepo := repository.NewJobRepository(dbPool)
	jobHandler := handlers.NewJobHandler(jobRepo)
	// ** ------------------------------------ **

	// Instantiate other repos/handlers here later...

	// --- Routes ---
	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
		defer cancel()
		err := dbPool.Ping(ctx) // Ping db connection from pool
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
		// --- News Routes ---
		apiV1.GET("/news", newsHandler.ListNews)
		apiV1.GET("/news/:id", newsHandler.GetNewsByID)
		// Add POST, PUT, DELETE for news later...

		// --- Job Routes ---
		apiV1.GET("/jobs", jobHandler.ListOpenJobs)   // List open jobs
		apiV1.GET("/jobs/:id", jobHandler.GetJobByID) // Get single job
		apiV1.POST("/jobs", jobHandler.CreateJob)     // Create a new job
		// Add PUT /jobs/:id, DELETE /jobs/:id later...
		// --- End Job Routes ---

		// Register other resource routes here later (events, directory, etc.)
	}
	log.Println("API routes registered.")

	// --- Start Server ---
	srv := &http.Server{
		Addr:    ":" + cfg.Port,
		Handler: router,
		// Consider adding Read/Write timeouts for production
		// ReadTimeout:  5 * time.Second,
		// WriteTimeout: 10 * time.Second,
		// IdleTimeout:  120 * time.Second,
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
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second) // 5 seconds to finish requests
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatal("Server forced to shutdown:", err)
	}

	log.Println("Server exiting")
}
