# VisionClaw Android

Native Android app (Kotlin + Jetpack Compose) for VisionClaw: AI assistant for Meta Ray-Ban smart glasses, using Gemini Live API and OpenClaw.

## Requirements

- Android Studio Ladybug (2024.2) or newer, or command-line SDK 34
- JDK 17
- **GitHub token** with `read:packages` scope (for Meta Wearables DAT dependency from GitHub Packages)

## Setup

1. **Clone and open**
   - Open `samples/CameraAccessAndroid` in Android Studio, or use the repo root and open this folder.

2. **Meta DAT dependency**
   - Create `local.properties` in `samples/CameraAccessAndroid/` with:
     ```properties
     github_token=YOUR_GITHUB_PERSONAL_ACCESS_TOKEN
     ```
   - Or set env var `GITHUB_TOKEN` when running Gradle.
   - Get a classic token from GitHub: Settings → Developer settings → Personal access tokens → `read:packages`.

3. **Run**
   - Connect a device or start an emulator (API 26+).
   - Run the `app` configuration.

## Structure

- **Gemini**: `GeminiConfig`, `GeminiLiveService` (WebSocket client for Gemini Live API).
- **OpenClaw**: `OpenClawBridge` (session and task delegation to OpenClaw gateway).
- **Settings**: `SettingsProvider` (Gemini API key, OpenClaw host/port/tokens).
- **UI**: Compose screens (Home, Settings, Stream placeholder); navigation in `NavGraph`.

## CI

- `.github/workflows/android-build.yml` builds the app on push/PR.
- Uses `GITHUB_TOKEN` to resolve the Meta DAT dependency; produces a debug APK artifact.

## Status

- ✅ Project scaffold, Gemini Live client, OpenClaw bridge, Settings, Home/Settings/Stream placeholder UI.
- 🚧 Stream screen (glasses + phone camera mode) and full DAT integration to be completed.
