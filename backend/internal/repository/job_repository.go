package repository

import (
	"context"
	"log"
	"village_project/internal/models" // Adjust import path

	// For generating UUID if needed
	"github.com/jackc/pgx/v5/pgxpool"
	// "errors" // Import if using ErrNotFound from news_repository.go
)

// JobRepository handles database operations for jobs
type JobRepository struct {
	DB *pgxpool.Pool
}

// NewJobRepository creates a new instance of JobRepository
func NewJobRepository(db *pgxpool.Pool) *JobRepository {
	return &JobRepository{DB: db}
}

// GetAllOpenJobs fetches all jobs with status 'Open', ordered by creation date descending
func (r *JobRepository) GetAllOpenJobs(ctx context.Context) ([]models.Job, error) {
	query := `
		SELECT id, created_at, updated_at, title, description, location,
		       payment_details, contact_info, status, posted_by_user_id, expires_at
		FROM public.jobs
		WHERE status = $1
		ORDER BY created_at DESC;
	`
	rows, err := r.DB.Query(ctx, query, "Open") // Filter by status = 'Open'
	if err != nil {
		log.Printf("Error querying open jobs: %v\n", err)
		return nil, err
	}
	defer rows.Close()

	var jobList []models.Job
	for rows.Next() {
		var job models.Job
		err := rows.Scan(
			&job.ID, &job.CreatedAt, &job.UpdatedAt, &job.Title, &job.Description, &job.Location,
			&job.PaymentDetails, &job.ContactInfo, &job.Status, &job.PostedByUserID, &job.ExpiresAt,
		)
		if err != nil {
			log.Printf("Error scanning job row: %v\n", err)
			continue
		}
		jobList = append(jobList, job)
	}

	if err = rows.Err(); err != nil {
		log.Printf("Error iterating job rows: %v\n", err)
		return nil, err
	}

	if jobList == nil {
		return []models.Job{}, nil // Return empty slice, not nil
	}
	return jobList, nil
}

// GetJobByID fetches a single job by its UUID
func (r *JobRepository) GetJobByID(ctx context.Context, id string) (models.Job, error) {
	query := `
		SELECT id, created_at, updated_at, title, description, location,
		       payment_details, contact_info, status, posted_by_user_id, expires_at
		FROM public.jobs
		WHERE id = $1;
	`
	var job models.Job
	err := r.DB.QueryRow(ctx, query, id).Scan(
		&job.ID, &job.CreatedAt, &job.UpdatedAt, &job.Title, &job.Description, &job.Location,
		&job.PaymentDetails, &job.ContactInfo, &job.Status, &job.PostedByUserID, &job.ExpiresAt,
	)

	if err != nil {
		// Assuming ErrNotFound is defined elsewhere or handle pgx.ErrNoRows directly
		// if errors.Is(err, pgx.ErrNoRows) { ... }
		log.Printf("Error querying job by ID %s: %v\n", id, err)
		return models.Job{}, err // Return error to handler to check type
	}
	return job, nil
}

// CreateJob inserts a new job posting into the database
func (r *JobRepository) CreateJob(ctx context.Context, jobData models.CreateJobRequest) (models.Job, error) {
	query := `
		INSERT INTO public.jobs
			(title, description, location, payment_details, contact_info, status, posted_by_user_id)
		VALUES
			($1, $2, $3, $4, $5, $6, $7)
		RETURNING id, created_at, updated_at, title, description, location,
		          payment_details, contact_info, status, posted_by_user_id, expires_at;
	`
	// For now, posted_by_user_id is NULL as we don't have auth implemented
	var postedByUserID *string // Pointer to string, can be nil

	// Generate a new UUID for the job ID (alternative: let DB generate it if default is set)

	var newJob models.Job
	err := r.DB.QueryRow(ctx, query,
		jobData.Title,
		jobData.Description,
		jobData.Location,       // Pass directly (string, nullable handled by DB)
		jobData.PaymentDetails, // Pass directly
		jobData.ContactInfo,
		"Open",         // Default status
		postedByUserID, // Pass nil pointer for now
	).Scan(
		&newJob.ID, &newJob.CreatedAt, &newJob.UpdatedAt, &newJob.Title, &newJob.Description, &newJob.Location,
		&newJob.PaymentDetails, &newJob.ContactInfo, &newJob.Status, &newJob.PostedByUserID, &newJob.ExpiresAt,
	)

	if err != nil {
		log.Printf("Error creating job: %v\n", err)
		return models.Job{}, err
	}

	log.Printf("Successfully created job with ID: %s", newJob.ID)
	return newJob, nil
}

// Add UpdateJob, DeleteJob later...
