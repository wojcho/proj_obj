package main

import (
	"encoding/json"
	"fmt"
	"io"
	"math"
	"net/http"
	"net/url"
	"time"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

type WeatherDto struct {
	Latitude                           float64   `gorm:"uniqueIndex:idx_weather"`
	Longitude                          float64   `gorm:"uniqueIndex:idx_weather"`
	Time                               time.Time `gorm:"uniqueIndex:idx_weather"`
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
	db      *gorm.DB
}

func NewWeatherProxy() *WeatherProxy {
	// open gorm sqlite DB
	db, err := gorm.Open(sqlite.Open("database.db"), &gorm.Config{})
	if err != nil {
		panic("failed to open weather DB: " + err.Error())
	}
	// migrate schema
	if err := db.AutoMigrate(&Weather{}); err != nil {
		panic("failed to migrate weather schema: " + err.Error())
	}

	return &WeatherProxy{
		baseURL: "https://api.open-meteo.com/v1/forecast",
		client:  &http.Client{Timeout: 10 * time.Second},
		db:      db,
	}
}

func roundToHour(t time.Time) time.Time {
	return t.Truncate(time.Hour).UTC()
}

func normalizeCoord(v float64) float64 {
	return math.Round(v*10000) / 10000
}

func (p *WeatherProxy) FetchWeatherNow(latitude, longitude float64) (*Weather, error) {
	latitude = normalizeCoord(latitude)
	longitude = normalizeCoord(longitude)
	now := time.Now().UTC()
	targetHour := roundToHour(now)

	// Check DB for existing record with equal latitude and longitude, and with time equal to targetHour
	var existing Weather
	if err := p.db.
		Where("latitude = ? AND longitude = ? AND time = ?", latitude, longitude, targetHour).
		First(&existing).Error; err == nil {
		return &existing, nil
	} else if err != nil && err != gorm.ErrRecordNotFound {
		return nil, fmt.Errorf("db query error: %w", err)
	}

	// Build request URL
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
	if n == 0 {
		return nil, fmt.Errorf("empty hourly data")
	}

	// Collect weathers and upsert into DB
	var closest Weather
	minDiff := time.Duration(1<<63 - 1)
	for i := 0; i < n; i++ {
		t, err := time.Parse("2006-01-02T15:04", om.Hourly.Time[i]) // iso8601
		t = t.UTC()                                                 // default timezone GMT https://open-meteo.com/en/docs#api_documentation

		w := Weather{
			WeatherDto: WeatherDto{
				Latitude:                           latitude,
				Longitude:                          longitude,
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

		// Upsert by trying to find existing row by lat/lon/time, if exists then update else create
		var dbRow Weather
		err = p.db.Where("latitude = ? AND longitude = ? AND time = ?", w.Latitude, w.Longitude, w.Time).First(&dbRow).Error
		if err == nil {
			// Update fields but keep ID/unique
			dbRow.TemperatureCelsius = w.TemperatureCelsius
			dbRow.RainMm = w.RainMm
			dbRow.PrecipitationProbabilityPercentage = w.PrecipitationProbabilityPercentage
			dbRow.SnowfallCm = w.SnowfallCm
			dbRow.VisibilityM = w.VisibilityM
			dbRow.WeatherCodeWmo = w.WeatherCodeWmo
			dbRow.SurfacePressureHpa = w.SurfacePressureHpa
			dbRow.CloudCoverPercentage = w.CloudCoverPercentage
			if err := p.db.Save(&dbRow).Error; err != nil {
				return nil, fmt.Errorf("db save error: %w", err)
			}
			w = dbRow
		} else if err == gorm.ErrRecordNotFound {
			if err := p.db.Create(&w).Error; err != nil {
				return nil, fmt.Errorf("db create error: %w", err)
			}
		} else {
			return nil, fmt.Errorf("db query error: %w", err)
		}

		// Choose closest to now
		d := w.Time.Sub(now)
		if d < 0 {
			d = -d
		}
		if d < minDiff {
			minDiff = d
			closest = w
		}
	}

	// If closest is zero value (meaning no rows inserted/read) then return error
	if closest.Time.IsZero() {
		return nil, fmt.Errorf("no correct weather rows")
	}

	// If the closest time equals targetHour then use closest record
	if roundToHour(closest.Time) == targetHour {
		return &closest, nil
	}

	// Try final DB lookup for the target hour
	var final Weather
	if err := p.db.Where("latitude = ? AND longitude = ? AND time = ?", latitude, longitude, targetHour).First(&final).Error; err == nil {
		return &final, nil
	}

	return nil, fmt.Errorf("closest value found but it differs from target value")
}
