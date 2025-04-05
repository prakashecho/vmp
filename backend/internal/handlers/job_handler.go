package handlers

import (
	"errors"
	"log"
	"net/http"
	"village_project/internal/models"     // Adjust import path
	"village_project/internal/repository" // Adjust import path

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5" // For pgx.ErrNoRows check
)

// JobHandler handles HTTP requests related to jobs
type JobHandler struct {
	Repo *repository.JobRepository
}

// NewJobHandler creates a new JobHandler
func NewJobHandler(repo *repository.JobRepository) *JobHandler {
	return &JobHandler{Repo: repo}
}

// ListOpenJobs godoc
// @Summary List open job postings
// @Description Get a list of all jobs currently marked as 'Open'
// @Tags jobs
// @Accept  json
// @Produce json
// @Success 200 {array} models.Job "Successfully retrieved list of open jobs"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/v1/jobs [get]
func (h *JobHandler) ListOpenJobs(c *gin.Context) {
	log.Println("Handler: ListOpenJobs called")

	jobList, err := h.Repo.GetAllOpenJobs(c.Request.Context())
	if err != nil {
		log.Printf("Error getting open jobs from repository: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve job listings"})
		return
	}

	log.Printf("Handler: Returning %d open jobs", len(jobList))
	c.JSON(http.StatusOK, jobList)
}

// GetJobByID godoc
// @Summary Get a single job by ID
// @Description Get details of a specific job using its UUID
// @Tags jobs
// @Accept  json
// @Produce json
// @Param   id   path      string  true  "Job ID (UUID)"
// @Success 200 {object} models.Job "Successfully retrieved job"
// @Failure 400 {object} map[string]string "Invalid ID format" // Not implemented yet
// @Failure 404 {object} map[string]string "Job not found"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/v1/jobs/{id} [get]
func (h *JobHandler) GetJobByID(c *gin.Context) {
	jobID := c.Param("id")
	log.Printf("Handler: GetJobByID called with ID: %s", jobID)

	job, err := h.Repo.GetJobByID(c.Request.Context(), jobID)
	if err != nil {
		// Check specifically for pgx.ErrNoRows
		if errors.Is(err, pgx.ErrNoRows) {
			log.Printf("Handler: Job not found for ID: %s", jobID)
			c.JSON(http.StatusNotFound, gin.H{"error": "Job not found"})
			return
		}
		// Handle other errors
		log.Printf("Error getting job by ID %s from repository: %v\n", jobID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve job details"})
		return
	}

	log.Printf("Handler: Returning job with ID: %s", jobID)
	c.JSON(http.StatusOK, job)
}

// CreateJob godoc
// @Summary Post a new job listing
// @Description Add a new job posting to the listings
// @Tags jobs
// @Accept  json
// @Produce json
// @Param   job body models.CreateJobRequest true "Job details"
// @Success 201 {object} models.Job "Successfully created job"
// @Failure 400 {object} map[string]string "Invalid input data"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/v1/jobs [post]
func (h *JobHandler) CreateJob(c *gin.Context) {
	log.Println("Handler: CreateJob called")
	var req models.CreateJobRequest

	// Bind JSON request body to the CreateJobRequest struct
	// and perform validation based on binding tags
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Printf("Error binding JSON for create job: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input data", "details": err.Error()})
		return
	}

	// Call repository to create the job
	newJob, err := h.Repo.CreateJob(c.Request.Context(), req)
	if err != nil {
		log.Printf("Error creating job in repository: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create job listing"})
		return
	}

	log.Printf("Handler: Successfully created job with ID: %s", newJob.ID)
	// Return 201 Created status and the newly created job object
	c.JSON(http.StatusCreated, newJob)
}
