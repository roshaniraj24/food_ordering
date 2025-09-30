# Food Order App

A modern Flutter food ordering application built with BloC architecture, featuring a beautiful UI with animations and a complete ordering flow.

## Features

- 🏪 Browse restaurants and menus
- 🛒 Add items to cart with quantity management
- 📱 Responsive design for mobile and web
- 🎨 Beautiful animations and UI components
- 💳 Complete checkout and order tracking
- 🌙 Clean architecture with BloC pattern

## Prerequisites

Before running this project, make sure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
- [Dart](https://dart.dev/get-dart) (version 3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- For Android development: Android SDK
- For iOS development: Xcode (macOS only)

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/roshaniraj24/food_ordering.git
   cd food_ordering
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code (for JSON serialization):**
   ```bash
   flutter pub run build_runner build
   ```

## Available Commands

### Development

- **Run the app on connected device/emulator:**
  ```bash
  flutter run
  ```

- **Run on specific platform:**
  ```bash
  # Android
  flutter run -d android

  # iOS (macOS only)
  flutter run -d ios

  # Web
  flutter run -d chrome

  # Windows
  flutter run -d windows

  # macOS
  flutter run -d macos

  # Linux
  flutter run -d linux
  ```

- **Hot reload (during development):**
  Press `r` in terminal while app is running

- **Hot restart:**
  Press `R` in terminal while app is running

### Building

- **Build APK for Android:**
  ```bash
  flutter build apk --release
  ```

- **Build AAB (Android App Bundle):**
  ```bash
  flutter build appbundle --release
  ```

- **Build IPA for iOS (macOS only):**
  ```bash
  flutter build ios --release
  ```

- **Build for Web:**
  ```bash
  flutter build web --release
  ```

- **Build for Desktop:**
  ```bash
  # Windows
  flutter build windows --release

  # macOS
  flutter build macos --release

  # Linux
  flutter build linux --release
  ```

### Testing

- **Run all tests:**
  ```bash
  flutter test
  ```

- **Run tests with coverage:**
  ```bash
  flutter test --coverage
  ```

- **Run specific test file:**
  ```bash
  flutter test test/path/to/test_file.dart
  ```

### Code Generation

- **Generate JSON serialization code:**
  ```bash
  flutter pub run build_runner build
  ```

- **Watch mode (auto-generate on changes):**
  ```bash
  flutter pub run build_runner watch
  ```

### Analysis & Linting

- **Analyze code:**
  ```bash
  flutter analyze
  ```

- **Format code:**
  ```bash
  flutter format lib/
  ```

### Cleaning

- **Clean build artifacts:**
  ```bash
  flutter clean
  ```

- **Clean and get dependencies:**
  ```bash
  flutter clean && flutter pub get
  ```

### Device Management

- **List connected devices:**
  ```bash
  flutter devices
  ```

- **Create emulator/device:**
  ```bash
  flutter emulators --create
  ```

- **Launch emulator:**
  ```bash
  flutter emulators --launch <emulator_id>
  ```

### Project Information

- **Check Flutter version:**
  ```bash
  flutter --version
  ```

- **Doctor (check setup):**
  ```bash
  flutter doctor
  ```

- **Check pub dependencies:**
  ```bash
  flutter pub outdated
  ```

## Project Structure

```
lib/
├── app.dart                 # App configuration
├── main.dart               # Entry point
├── core/                   # Core utilities
│   ├── failures.dart       # Error handling
│   └── result.dart         # Result wrapper
├── data/                   # Data layer
│   ├── models/            # Data models
│   └── repositories/      # Data repositories
├── presentation/          # Presentation layer
│   ├── bloc/             # BLoC state management
│   ├── screens/          # UI screens
│   ├── theme/            # App theme
│   └── widgets/          # Reusable widgets
└── test/                  # Unit and widget tests
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
