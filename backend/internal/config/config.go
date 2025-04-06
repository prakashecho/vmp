package config

import (
	// Import "fmt" only if used elsewhere now, likely not needed here anymore
	"fmt"
	"log"
	// Keep "strings" only if used elsewhere, likely not needed here anymore
	// "strings"

	"github.com/spf13/viper"
)

// Config holds all configuration for the application
type Config struct {
	Port               string `mapstructure:"PORT"`
	SupabaseURL        string `mapstructure:"SUPABASE_URL"`         // Keep for potential API calls
	SupabaseAnonKey    string `mapstructure:"SUPABASE_ANON_KEY"`    // Keep for potential API calls
	SupabaseServiceKey string `mapstructure:"SUPABASE_SERVICE_KEY"` // Keep for API calls
	DatabaseURL        string `mapstructure:"DATABASE_URL"`         // Primary connection string (will hold pooler URL)
	CorsAllowedOrigins string `mapstructure:"CORS_ALLOWED_ORIGINS"`
	GinMode            string `mapstructure:"GIN_MODE"`
	// DBPassword is no longer needed here if using the full DATABASE_URL from pooler
	// DBPassword         string `mapstructure:"DB_PASSWORD"`
}

// LoadConfig reads configuration from file or environment variables.
func LoadConfig(path string) (config Config, err error) {
	viper.AddConfigPath(path)   // Path to look for the config file in
	viper.SetConfigName(".env") // Name of config file (without extension)
	viper.SetConfigType("env")  // Look for specific type

	viper.AutomaticEnv() // Read in environment variables that match

	// Set default values
	viper.SetDefault("PORT", "8080")
	viper.SetDefault("CORS_ALLOWED_ORIGINS", "http://localhost:3000")
	viper.SetDefault("GIN_MODE", "debug") // Default Gin mode

	// Attempt to read .env file first (useful for local overrides)
	err = viper.ReadInConfig()
	if err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			// Only log error if it's NOT a file not found error
			log.Printf("Warning: Error reading config file: %s\n", err)
        } else {
            log.Println("Config file (.env) not found, relying on environment variables or defaults.")
        }
        // Proceed even if .env is not found, environment variables take precedence
        err = nil
	}

	// Unmarshal all values found (from file or environment variables)
	err = viper.Unmarshal(&config)
	if err != nil {
		log.Fatalf("Unable to decode config into struct: %v", err)
		// return - Unreachable due to Fatalf
	}

	// --- SIMPLIFIED Database URL Logic ---
	// Get DATABASE_URL directly after unmarshalling.
	// viper.AutomaticEnv() ensures environment variable takes precedence over file.
	config.DatabaseURL = viper.GetString("DATABASE_URL")
	// -------------------------------------


	// --- Validate essential configs ---
	if config.DatabaseURL == "" {
		// This is now a critical error if DATABASE_URL is not set via env var or file
		err = fmt.Errorf("DATABASE_URL environment variable is required but not set or empty")
		return
	}
	// Remove check for SupabaseURL unless needed for non-DB API calls
	// if config.SupabaseURL == "" { ... }

	// Service key is likely still needed for Supabase API interactions (e.g., auth)
	if config.SupabaseServiceKey == "" {
		err = fmt.Errorf("SUPABASE_SERVICE_KEY environment variable is required")
		return
	}
	// Remove DBPassword validation
	// if viper.GetString("DB_PASSWORD") == "" { ... }

	log.Printf("Using Database URL: %s", config.DatabaseURL) // Log the URL being used
	log.Println("Configuration loaded successfully.")
	return
}
