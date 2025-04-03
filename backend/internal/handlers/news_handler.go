package handlers

import (
	"log"
	"net/http"

	// Adjust import paths based on your go.mod module name
	"village_project/internal/repository"

	"github.com/gin-gonic/gin"
)

// NewsHandler handles HTTP requests related to news
type NewsHandler struct {
	// Embed the repository
	Repo *repository.NewsRepository
}

// NewNewsHandler creates a new NewsHandler
func NewNewsHandler(repo *repository.NewsRepository) *NewsHandler {
	return &NewsHandler{Repo: repo}
}

// ListNews godoc
// @Summary List published news items
// @Description Get a list of all published news items, ordered by most recent
// @Tags news
// @Accept  json
// @Produce json
// @Success 200 {array} models.News "Successfully retrieved list of news"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /api/v1/news [get]
func (h *NewsHandler) ListNews(c *gin.Context) {
	log.Println("Handler: ListNews called") // Log handler entry

	newsList, err := h.Repo.GetAllPublishedNews(c.Request.Context())
	if err != nil {
		log.Printf("Error getting news from repository: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve news"})
		return
	}

	log.Printf("Handler: Returning %d news items", len(newsList)) // Log success
	c.JSON(http.StatusOK, newsList)                               // Return the list as JSON
}

// Add handlers here later for GetNewsByID, CreateNews, UpdateNews, DeleteNews etc.
