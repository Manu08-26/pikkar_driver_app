# Pikkar Driver App

A professional Flutter application for ride-sharing drivers.

## Features

- 🔐 **Authentication** - Secure login and OTP verification
- 📍 **Real-time Location Tracking** - GPS tracking for rides
- 🚗 **Ride Management** - Accept, start, and complete rides
- 💰 **Earnings Tracking** - Monitor daily and weekly earnings
- 👤 **Profile Management** - Update driver information and documents
- 🔔 **Push Notifications** - Real-time ride requests
- 🗺️ **Maps Integration** - Google Maps with navigation

## Project Structure

```
lib/
├── core/           # Core functionality (constants, theme, utils)
├── data/           # Data layer (models, repositories, data sources)
├── domain/         # Business logic (entities, use cases)
├── presentation/   # UI layer (screens, widgets, providers)
├── routes/         # Navigation setup
└── services/       # Services (location, notifications, etc.)
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Android Studio / Xcode
- Firebase project setup

### Installation

1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase for Android and iOS
4. Run the app: `flutter run`

## Configuration

### Android Setup

1. Add your `google-services.json` in `android/app/`
2. Configure Google Maps API key in `AndroidManifest.xml`

### iOS Setup

1. Add your `GoogleService-Info.plist` in `ios/Runner/`
2. Configure Google Maps API key in `AppDelegate.swift`

## Architecture

This project follows Clean Architecture principles with three main layers:

- **Presentation Layer**: UI components and state management
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Data sources and repository implementations

## State Management

Using Provider/Riverpod for state management across the app.

## License

Copyright © 2026 Pikkar. All rights reserved.

