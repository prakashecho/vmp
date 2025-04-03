package config

import (
	"fmt"
	"log"
	"strings"

	"github.com/spf13/viper"
)

// Config holds all configuration for the application
type Config struct {
	Port               string `mapstructure:"PORT"`
	SupabaseURL        string `mapstructure:"SUPABASE_URL"`
	SupabaseAnonKey    string `mapstructure:"SUPABASE_ANON_KEY"`    // Public key
	SupabaseServiceKey string `mapstructure:"SUPABASE_SERVICE_KEY"` // Secret key!
	DatabaseURL        string `mapstructure:"DATABASE_URL"`         // PostgreSQL connection string
	CorsAllowedOrigins string `mapstructure:"CORS_ALLOWED_ORIGINS"`
}

// LoadConfig reads configuration from file or environment variables.
func LoadConfig(path string) (config Config, err error) {
	viper.AddConfigPath(path)   // Path to look for the config file in
	viper.SetConfigName(".env") // Name of config file (without extension)
	viper.SetConfigType("env")  // Look for specific type

	viper.AutomaticEnv() // Read in environment variables that match

	// Set default values
	viper.SetDefault("PORT", "8080")
	viper.SetDefault("CORS_ALLOWED_ORIGINS", "http://localhost:3000") // Default for local Flutter dev

	err = viper.ReadInConfig() // Find and read the config file
	if err != nil {
		// Ignore file not found error, rely on env vars or defaults
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			log.Printf("Error reading config file: %s\n", err)
			// Don't return error here if file not found is okay
		} else {
			log.Println("Config file (.env) not found, using environment variables or defaults.")
		}
		// Reset error if it was just file not found
		err = nil
	}

	err = viper.Unmarshal(&config)
	if err != nil {
		log.Fatalf("Unable to decode into struct: %v", err)
		return
	}

	// Construct DatabaseURL if not explicitly set but Supabase details are
	if config.DatabaseURL == "" && config.SupabaseURL != "" && config.SupabaseServiceKey != "" {
		// Extract project ref from SupabaseURL (e.g., https://<ref>.supabase.co -> <ref>)
		projectRef := ""
		parts := strings.Split(strings.TrimPrefix(config.SupabaseURL, "https://"), ".")
		if len(parts) > 0 {
			projectRef = parts[0]
		}

		if projectRef != "" {
			// Standard Supabase DB connection string format
			// Note: Password is the one you set when creating the Supabase project!
			// You SHOULD get the password from env vars, not hardcode it.
			// Adding a placeholder here - replace with env var loading!
			dbPassword := viper.GetString("DB_PASSWORD") // Read DB_PASSWORD from env
			if dbPassword == "" {
				log.Println("Warning: DB_PASSWORD environment variable not set. Database connection may fail.")
				// Optionally, set err here if password is required
				// err = fmt.Errorf("DB_PASSWORD environment variable is required")
				// return
			}
			config.DatabaseURL = fmt.Sprintf("postgresql://postgres:%s@db.%s.supabase.co:5432/postgres",
				dbPassword,
				projectRef,
			)
			// Re-set in viper in case it's used elsewhere via viper.Get
			viper.Set("DATABASE_URL", config.DatabaseURL)
		} else {
			err = fmt.Errorf("could not derive projectRef from SUPABASE_URL to build DATABASE_URL")
			return
		}

	}

	// Validate essential configs
	if config.DatabaseURL == "" {
		err = fmt.Errorf("DATABASE_URL is required but could not be loaded or derived")
		return
	}
	if config.SupabaseServiceKey == "" {
		err = fmt.Errorf("SUPABASE_SERVICE_KEY is required")
		return
	}

	log.Println("Configuration loaded successfully.")
	// log.Printf("Debug: Loaded Config = %+v\n", config) // Uncomment for debugging

	return
}
