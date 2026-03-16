# 🌤️ Weather App

A modern, responsive desktop weather application built with **Qt 6** and **QML**, featuring a frameless custom window, real-time weather data, and a clean UI with emoji-driven visual indicators.

---

## Preview

> [Video of the app](https://drive.google.com/file/d/1vPNCPcpHF7J4_vA89kN_IO6Z7uxnAVNy/view?usp=drive_link)

---

## ✨ Features

- 🔍 **City Search** — Search any city worldwide by name using the Open-Meteo Geocoding API
- 🌡️ **Current Conditions** — Temperature, feels-like, weather description, and weather emoji driven by WMO weather codes
- ⏱️ **Hourly Forecast** — Horizontally scrollable 24-hour temperature breakdown, with the current hour highlighted
- 📅 **7-Day Forecast** — Daily max/min temperatures with UV index, color-coded by severity
- 💨 **Weather Details Grid** — Wind speed, humidity, wind direction, and atmospheric pressure
- 🔄 **Refresh Button** — Re-fetch the last queried city with one click
- 🪟 **Custom Frameless Window** — Native-feel title bar with minimize, maximize/restore, and close buttons
- ↔️ **Full Window Resizing** — Resize from any edge or corner using native OS system resize
- 📐 **Fully Responsive UI** — All sizes, fonts, and spacing are relative to window dimensions
- 🌍 **Timezone-Aware** — All times are returned in the searched city's local timezone

---

## 🏗️ Project Structure

```
Task04_Weather/
├── Main.qml                  # Root window, UI layout, models, API signal handlers
├── main.cpp                  # Qt application entry point
├── CMakeLists.txt            # Build configuration
├── resources.qrc             # Embedded resources (images)
├── images/
│   └── weatherbackground.jpg # App background image
├── API/
│   └── WeatherAPI.qml        # API abstraction layer (geocoding + weather fetch)
└── Components/
    ├── WindowBar.qml         # Custom frameless title bar
    └── WindowResize.qml      # Full-window edge & corner resize handlers
```

---

## 🔌 APIs Used

| API | Purpose | Docs |
|-----|---------|------|
| [Open-Meteo Geocoding API](https://open-meteo.com/en/docs/geocoding-api) | Convert city name → coordinates + timezone | Free, no key required |
| [Open-Meteo Forecast API](https://open-meteo.com/en/docs) | Fetch current, hourly, and daily weather | Free, no key required |

### Parameters fetched

**Current:** `temperature_2m`, `apparent_temperature`, `weather_code`, `wind_speed_10m`, `wind_direction_10m`, `surface_pressure`, `rain`, `relative_humidity_2m`, `cloud_cover`, `is_day`, `time`

**Hourly:** `temperature_2m` (24 hours)

**Daily:** `temperature_2m_max`, `temperature_2m_min`, `uv_index_max` (7 days)

---

## 🧱 Architecture

The app follows a clean **separation of concerns**:

```
WeatherAPI.qml          →   signals   →   Main.qml
(fetch, parse JSON)                    (update UI models)
```

- `WeatherAPI.qml` is a pure `QtObject` with no UI references — it only emits signals
- `Main.qml` listens to signals and updates `ListModel`s and bound `Text` elements
- UI components (`WindowBar`, `WindowResize`) communicate back via `required property var window`

---

## 🚀 Getting Started

### Prerequisites

- **Qt 6.8+** with the following modules:
  - `Qt6::Quick`
- **CMake 3.16+**
- **C++17** compatible compiler

### Build & Run

```bash
# Clone or extract the project
cd Task04_Weather

# Configure
cmake -B build -S .

# Build
cmake --build build

# Run
./build/appTask04_Weather
```

Or open the project directly in **Qt Creator** via `CMakeLists.txt`.

---

## 🎨 UI Components

### `WindowBar.qml`
Custom title bar `Rectangle` that:
- Drags the window via `startSystemMove()`
- Toggles maximize/restore with state-aware icon (`□` / `❐`)
- Hover animations on all control buttons
- Requires a `window` property pointing to the `ApplicationWindow`

### `WindowResize.qml`
Transparent `Item` that fills the entire window and provides:
- 4 edge resize handles (top, bottom, left, right)
- 4 corner resize handles with correct diagonal cursors
- Uses native `startSystemResize()` for OS-level resize handling

### `WeatherAPI.qml`
API abstraction `QtObject` that:
- Exposes a single `fetch(city)` public function
- Internally chains: geocoding → weather forecast
- Emits `weatherReceived(current, daily, hourly, location, population)` on success
- Emits `cityNotFound(city)` or `networkError(message)` on failure

---

## 🌈 UV Index Color Scale

| UV Range | Emoji | Color | Level |
|----------|-------|-------|-------|
| 0–2 | 🌤 | 🟢 Green | Low |
| 3–5 | ☀️ | 🟡 Yellow | Moderate |
| 6–7 | 🌞 | 🟠 Orange | High |
| 8–10 | 🔆 | 🔴 Red | Very High |
| 11+ | 🔥 | 🟣 Purple | Extreme |

---

## 🌦️ Weather Code → Emoji Mapping

| WMO Code | Condition | Day | Night |
|----------|-----------|-----|-------|
| 0 | Clear sky | ☀️ | 🌙 |
| 1–2 | Partly cloudy | 🌤️ | 🌙 |
| 3 | Overcast | ☁️ | ☁️ |
| 45–48 | Foggy | 🌫️ | 🌫️ |
| 51–55 | Drizzle | 🌦️ | 🌦️ |
| 61–65 | Rain | 🌧️ | 🌧️ |
| 71–75 | Snow | ❄️ | ❄️ |
| 80–82 | Rain showers | 🌦️ | 🌦️ |
| 95–99 | Thunderstorm | ⛈️ | ⛈️ |

---

## 📦 Dependencies

| Dependency | Version | Notes |
|------------|---------|-------|
| Qt Quick | 6.8+ | Core UI framework |
| Qt Quick Controls | 6.8+ | `ApplicationWindow`, `TextField`, `Button` |
| Open-Meteo | — | Free weather API, no API key needed |
