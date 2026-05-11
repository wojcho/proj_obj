import (
	"time"
	"gorm.io/gorm"
)

type Weather struct {
	gorm.Model
	latitude float
	longitude float
	time time.Time
	temperatureCelsius float
	rainMm float
	precipitationProbabilityPercentage float
	snowfallCm float
	visibilityM float
	weatherCodeWmo float
	surfacePressureHpa float
	cloudCoverPercentage float
}
