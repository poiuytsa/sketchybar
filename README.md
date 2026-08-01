# 🍎 SketchyBar

A minimal, macOS-inspired SketchyBar configuration focused on clean design, smooth interactions, and a polished Spotify experience.

<p align="center">
  <img src="assets/Screenshot.png" width="100%">
</p>

---

## ✨ Features

### 🎵 Spotify
- Live Spotify integration
- Dynamic album artwork
- Album-aware capsule tint
- Previous / Play-Pause / Next controls
- Scrolling song titles
- Opens Spotify on click

### 📊 System

- CPU usage with live sparkline history
- Smart battery widget
  - 🟢 Green while charging
  - ⚪ White above 20%
  - 🟡 Yellow below 20%
  - 🔴 Red below 10%
- Volume indicator
- Wi-Fi status
- Clock

### 🎨 Design

- Glassmorphism-inspired interface
- Floating rounded menu bar
- Dynamic Spotify colors based on album art
- Native SF Symbols
- SF Pro typography
- Consistent spacing and rounded capsules

---

## 📦 Requirements

- macOS
- SketchyBar
- ImageMagick
- nowplaying-cli
- SF Pro
- JetBrainsMono Nerd Font

---

## 🚀 Installation

```bash
git clone https://github.com/poiuytsa/sketchybar.git

cp -R sketchybar ~/.config/

brew services restart sketchybar
```

---

## 📁 Structure

```
sketchybar/
│
├── plugins/
│   ├── spotify.sh
│   ├── spotify_artwork.sh
│   ├── battery.sh
│   ├── cpu.sh
│   ├── volume.sh
│   ├── wifi.sh
│   └── clock.sh
│
└── sketchybarrc
```

