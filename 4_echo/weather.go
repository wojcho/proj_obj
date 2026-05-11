package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"time"

	"gorm.io/gorm"
)

type WeatherDto struct {
	Latitude                           float64   `json:"latitude"`
	Longitude                          float64   `json:"longitude"`
	Time                               time.Time `json:"time"`
	TemperatureCelsius                 float64   `json:"temperatureCelsius"`
	RainMm                             float64   `json:"rainMm"`
	PrecipitationProbabilityPercentage float64   `json:"precipitationProbabilityPercentage"`
	SnowfallCm                         float64   `json:"snowfallCm"`
	VisibilityM                        float64   `json:"visibilityM"`
	WeatherCodeWmo                     float64   `json:"weatherCodeWmo"`
	SurfacePressureHpa                 float64   `json:"surfacePressureHpa"`
	CloudCoverPercentage               float64   `json:"cloudCoverPercentage"`
}

type Weather struct {
	gorm.Model
	WeatherDto
}

func (w *Weather) ToDto() WeatherDto {
	return WeatherDto{
		Latitude:                           w.Latitude,
		Longitude:                          w.Longitude,
		Time:                               w.Time,
		TemperatureCelsius:                 w.TemperatureCelsius,
		RainMm:                             w.RainMm,
		PrecipitationProbabilityPercentage: w.PrecipitationProbabilityPercentage,
		SnowfallCm:                         w.SnowfallCm,
		VisibilityM:                        w.VisibilityM,
		WeatherCodeWmo:                     w.WeatherCodeWmo,
		SurfacePressureHpa:                 w.SurfacePressureHpa,
		CloudCoverPercentage:               w.CloudCoverPercentage,
	}
}

type omResponse struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Hourly    struct {
		Time                     []string  `json:"time"`
		Temperature2m            []float64 `json:"temperature_2m"`
		Rain                     []float64 `json:"rain"`
		PrecipitationProbability []float64 `json:"precipitation_probability"`
		Snowfall                 []float64 `json:"snowfall"`
		Visibility               []float64 `json:"visibility"`
		WeatherCode              []float64 `json:"weather_code"`
		SurfacePressure          []float64 `json:"surface_pressure"`
		CloudCover               []float64 `json:"cloud_cover"`
	} `json:"hourly"`
}

// Simple proxy responsible for fetching data from Open-Meteo API and mapping that data to obtain current Weather
type WeatherProxy struct {
	baseURL string
	client  *http.Client
}

func NewWeatherProxy() *WeatherProxy {
	return &WeatherProxy{
		baseURL: "https://api.open-meteo.com/v1/forecast",
		client:  &http.Client{Timeout: 10 * time.Second},
	}
}

func (p *WeatherProxy) FetchWeatherNow(latitude, longitude float64) (*Weather, error) {
	u, err := url.Parse(p.baseURL)
	if err != nil {
		return nil, fmt.Errorf("invalid base url: %w", err)
	}

	q := u.Query()
	q.Set("latitude", fmt.Sprintf("%f", latitude))
	q.Set("longitude", fmt.Sprintf("%f", longitude))
	q.Set("hourly", "temperature_2m,rain,precipitation_probability,snowfall,visibility,weather_code,surface_pressure,cloud_cover")
	q.Set("forecast_days", "1")
	u.RawQuery = q.Encode()

	resp, err := p.client.Get(u.String())
	if err != nil {
		return nil, fmt.Errorf("failed to fetch remote weather: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(io.LimitReader(resp.Body, 4096))
		return nil, fmt.Errorf("remote returned status %d: %s", resp.StatusCode, string(body))
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read body: %w", err)
	}

	// Decode Open-Meteo response to struct from JSON
	var om omResponse
	if err := json.Unmarshal(body, &om); err != nil {
		return nil, fmt.Errorf("unmarshal open-meteo response: %w", err)
	}

	n := len(om.Hourly.Time)
	weathers := make([]Weather, 0, n)
	for i := 0; i < n; i++ {
		t, _ := time.Parse("2006-01-02T15:04", om.Hourly.Time[i])

		w := Weather{
			WeatherDto: WeatherDto{
				Latitude:                           om.Latitude,
				Longitude:                          om.Longitude,
				Time:                               t,
				TemperatureCelsius:                 om.Hourly.Temperature2m[i],
				RainMm:                             om.Hourly.Rain[i],
				PrecipitationProbabilityPercentage: om.Hourly.PrecipitationProbability[i],
				SnowfallCm:                         om.Hourly.Snowfall[i],
				VisibilityM:                        om.Hourly.Visibility[i],
				WeatherCodeWmo:                     om.Hourly.WeatherCode[i],
				SurfacePressureHpa:                 om.Hourly.SurfacePressure[i],
				CloudCoverPercentage:               om.Hourly.CloudCover[i],
			},
		}

		weathers = append(weathers, w)
	}

	now := time.Now().UTC()
	closestIdx := 0
	minDiff := time.Duration(1<<63 - 1) // init with max possible, time.Duration is int64 of nanoseconds
	for i, w := range weathers {
		d := w.Time.Sub(now)
		if d < 0 {
			d = -d
		}
		if d < minDiff {
			minDiff = d
			closestIdx = i
		}
	}
	return &weathers[closestIdx], nil
}
