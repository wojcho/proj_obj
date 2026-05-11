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

	cities := map[string][2]float64{
		"krakow":    {50.0646, 19.9449},
		"warszawa":  {52.2277, 21.0018},
		"praga":     {50.0875, 14.4212},
		"budapeszt": {47.5072, 19.0450},
	}

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

	e.GET("/weather/:city", func(c *echo.Context) error {
		city := c.Param("city")
		coords, ok := cities[city]
		if !ok {
			return c.String(http.StatusNotFound, "unknown city")
		}
		lat, lon := coords[0], coords[1]
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
