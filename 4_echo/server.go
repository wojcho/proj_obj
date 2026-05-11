package main

import (
	"fmt"
	"strconv"

	"net/http"

	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"
)

func main() {
	e := echo.New()
	e.Use(middleware.RequestLogger())

	e.GET("/weather", func(c *echo.Context) error {
		latStr := c.QueryParam("latitude")
		lonStr := c.QueryParam("longitude")

		lat, err := strconv.ParseFloat(latStr, 64)
		if err != nil {
			return c.String(http.StatusBadRequest, fmt.Sprintf("incorrect latitude: %v", err))
		}
		lon, err := strconv.ParseFloat(lonStr, 64)
		if err != nil {
			return c.String(http.StatusBadRequest, fmt.Sprintf("incorrect longitude: %v", err))
		}

		return c.String(http.StatusOK, fmt.Sprintf("weather at lat=%f lon=%f sunny", lat, lon))
	})

	if err := e.Start(":1323"); err != nil {
		e.Logger.Error("failed to start server", "error", err)
	}
}
