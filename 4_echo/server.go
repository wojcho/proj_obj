package main

import (
	"strconv"

	"net/http"

	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"
)

func main() {
	e := echo.New()
	e.Use(middleware.RequestLogger())

	proxy := NewWeatherProxy()

	e.GET("/weather", func(c *echo.Context) error {
		latStr := c.QueryParam("latitude")
		lonStr := c.QueryParam("longitude")

		lat, err := strconv.ParseFloat(latStr, 64)
		if err != nil {
			return c.String(http.StatusBadRequest, "incorrect latitude: "+err.Error())
		}
		lon, err := strconv.ParseFloat(lonStr, 64)
		if err != nil {
			return c.String(http.StatusBadRequest, "incorrect longitude: "+err.Error())
		}

		w, err := proxy.FetchWeatherNow(lat, lon)
		if err != nil {
			return c.String(http.StatusInternalServerError, "failed to fetch weather: "+err.Error())
		}
		return c.JSON(http.StatusOK, w.ToDto())
	})

	if err := e.Start(":1323"); err != nil {
		e.Logger.Error("failed to start server", "error", err)
	}
}
