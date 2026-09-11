# TravelBuddy 🏔️  
*Your AI-powered Himalayan & Indian Travel & Trekking Companion*

TravelBuddy is a production-grade Flutter application built for exploring trekking destinations, curating personalized itineraries, managing offline trip maps, and connecting with a vibrant trekking community across India.

---

## 🌟 Key Features
- **Interactive Trek Map & Discovery**: Dynamic map visualization with state, terrain, difficulty, and weather-aware filters.
- **Live OpenWeatherMap Integration**: Real-time base camp weather conditions, 5-day forecasts, and seasonal best-month indicators.
- **Offline Map Region Manager**: Downloadable map regions for high-altitude Himalayan treks with storage management and progress tracking.
- **Community Buddy Finder & Q&A**: Connect with fellow trekkers, post upcoming trips, and ask region-specific travel questions.
- **Emergency SOS Hub**: Instant access to local police, forest department helplines, nearest hospital navigation, and one-tap GPS coordinate sharing.
- **Feature-Flagged Architecture**: Seamless fallback mechanism toggling between live cloud backend services and local offline mock data.

---

## 🚀 Getting Started & Configuration

### 1. Environment Setup
Copy `.env.example` to `.env` in the root of the project:

```bash
cp .env.example .env
```

### 2. Configure API Keys
Edit `.env` and fill in your service credentials:

```ini
# Feature Flag: Set to false to enable real cloud services
USE_MOCK_DATA=true

# OpenWeatherMap API Key (Get from https://openweathermap.org/api)
OPENWEATHER_API_KEY=your_openweather_api_key_here

# Firebase Backend Configuration (Optional for cloud sync)
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_API_KEY=your_firebase_api_key
```

---

## 🧪 Running Tests & Quality Verification

Run the full suite of unit and widget tests:

```bash
flutter test
```

Run static analysis to verify code quality:

```bash
flutter analyze
```

---

## 📂 Project Architecture & Documentation

- `OFFLINE_MAPS_EVALUATION.md`: Architectural tradeoff analysis comparing Mapbox vector tile caching vs Google Maps custom overlays.
- `lib/core/config/env_config.dart`: Centralized environment manager reading `.env` variables and controlling feature flags.
- `lib/services/`: Cloud services layer (`WeatherService`, `AuthService`, `RemoteDestinationRepository`, `ReviewService`, `NotificationService`).
