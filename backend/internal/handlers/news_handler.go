package handlers

import (
	"errors"
	"log"
	"net/http"
	"village_project/internal/repository" // Adjust import path

	"github.com/gin-gonic/gin"
)

// NewsHandler handles HTTP requests related to news
type NewsHandler struct {
	Repo *repository.NewsRepository
}

// NewNewsHandler creates a new NewsHandler
func NewNewsHandler(repo *repository.NewsRepository) *NewsHandler {
	return &NewsHandler{Repo: repo}
}

// ListNews fetches all published news
func (h *NewsHandler) ListNews(c *gin.Context) {
	log.Println("Handler: ListNews called")
	newsList, err := h.Repo.GetAllPublishedNews(c.Request.Context())
	if err != nil {
		log.Printf("Error getting news from repository: %v\n", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve news"})
		return
	}
	log.Printf("Handler: Returning %d news items", len(newsList))
	c.JSON(http.StatusOK, newsList)
}

// GetNewsByID fetches a single news item by ID
// ** MAKE SURE THIS METHOD NAME AND RECEIVER ARE EXACTLY LIKE THIS **
func (h *NewsHandler) GetNewsByID(c *gin.Context) {
	itemID := c.Param("id")
	log.Printf("Handler: GetNewsByID called with ID: %s", itemID)

	newsItem, err := h.Repo.GetNewsByID(c.Request.Context(), itemID)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			log.Printf("Handler: News item not found for ID: %s", itemID)
			c.JSON(http.StatusNotFound, gin.H{"error": "News item not found"})
			return
		}
		log.Printf("Error getting news by ID %s from repository: %v\n", itemID, err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve news item"})
		return
	}

	log.Printf("Handler: Returning news item with ID: %s", itemID)
	c.JSON(http.StatusOK, newsItem)
}
