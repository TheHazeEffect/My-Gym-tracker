# 🏋️‍♂️ Gym Tracker

A comprehensive Flutter-based fitness tracking application designed to help you monitor your workout progress, manage rest timers, and analyze your fitness journey over time.

[![Flutter CI/CD](https://github.com/TheHazeEffect/My-Gym-tracker/workflows/Flutter%20CI/CD/badge.svg)](https://github.com/TheHazeEffect/My-Gym-tracker/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## 📱 App Overview

Gym Tracker is a modern, intuitive fitness app that focuses on weight progression tracking and comprehensive workout management. Built with Flutter, it provides a seamless experience for logging workouts, tracking personal records, and managing your fitness routine with advanced timer functionality.

## ✨ Key Features

### 🏃‍♂️ Workout Management
- **Start & Continue Workouts**: Easy workout session management with real-time tracking
- **Exercise Library**: Comprehensive exercise database with muscle group targeting
- **Set Tracking**: Log sets, reps, and weights with automatic personal record detection
- **Edit Past Workouts**: Full editing capabilities for historical workout data
- **Progress Photos**: Document your fitness journey with integrated photo tracking

### 📊 Progress Analytics
- **Weight Progression Charts**: Visual charts showing strength gains over time using FL Chart
- **Personal Records**: Automatic tracking and highlighting of maximum working sets
- **Exercise Search & Filter**: Quick filtering and analysis of specific exercises
- **Muscle Group Analytics**: Track primary, secondary, and tertiary muscle group development
- **Monthly Statistics**: View workout frequency and progress trends

### ⏱️ Advanced Timer System
- **Multiple Concurrent Timers**: Run several rest timers simultaneously for complex workouts
- **Smart Alerts**: Haptic feedback and visual notifications when timers complete
- **Persistent Timers**: Timers remain visible after completion for easy reference
- **Quick Timer Presets**: 1-minute, 3-minute, and 5-minute quick-start options
- **Custom Timer Durations**: Set any duration for specialized rest periods

### 📅 Workout History & Calendar
- **Calendar Integration**: Monthly calendar view with workout highlights using Table Calendar
- **Day Filtering**: Filter and view workouts by specific dates
- **Detailed History**: Complete workout logs with exercise breakdowns and volume tracking
- **Statistics Dashboard**: Track total workouts, unique exercises, and monthly progress
- **Export Data**: Backup and export your workout data

### 🎨 User Experience
- **Modern Green Theme**: Clean, accessible design with proper contrast ratios
- **Tabbed Navigation**: Intuitive organization of workout, progress, timer, and settings features
- **Responsive Design**: Optimized for various screen sizes and orientations
- **Dark Mode Ready**: Prepared for future dark theme implementation
- **Accessibility**: High contrast ratios and screen reader compatibility

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider pattern with MVVM architecture
- **Local Storage**: Hive (NoSQL database) for fast, offline-first data persistence
- **Charts**: FL Chart for beautiful data visualization
- **Calendar**: Table Calendar for workout history and scheduling
- **Architecture**: MVVM (Model-View-ViewModel) with clean separation of concerns

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8      # iOS-style icons
  hive: ^2.2.3                 # Local NoSQL database
  hive_flutter: ^1.1.0         # Flutter integration for Hive
  provider: ^6.1.5+1           # State management solution
  fl_chart: ^1.0.0             # Beautiful charts and graphs
  table_calendar: ^3.1.2       # Calendar widget for workout history
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0        # Code quality and style enforcement
  hive_generator: ^2.0.1       # Code generation for Hive adapters
  build_runner: ^2.4.6         # Build system for code generation
```

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.9.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/TheHazeEffect/My-Gym-tracker.git
   cd My-Gym-tracker
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive type adapters**
   ```bash
   dart run build_runner build
   ```
   *Note: Run this whenever you modify Hive model classes*

4. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```
   *Ensure all checkmarks are green*

5. **Run the application**
   ```bash
   # Development mode
   flutter run
   
   # Release mode (optimized performance)
   flutter run --release
   ```

### Development Setup

1. **Enable additional platforms (optional)**
   ```bash
   flutter config --enable-web
   flutter config --enable-macos-desktop
   flutter config --enable-windows-desktop
   ```

2. **Run tests**
   ```bash
   flutter test
   ```

3. **Code analysis and formatting**
   ```bash
   # Analyze code for issues
   flutter analyze
   
   # Format code according to Dart style
   dart format .
   ```

4. **Generate coverage report**
   ```bash
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   ```

## 🏗️ Building for Production

### Android
```bash
# Build APK (for direct installation)
flutter build apk --release

# Build App Bundle (for Google Play Store)
flutter build appbundle --release

# Build APK with split per ABI (smaller file sizes)
flutter build apk --split-per-abi --release
```

### iOS (macOS required)
```bash
# Build for iOS
flutter build ios --release
```

### Web
```bash
# Build for web deployment
flutter build web --release
```

## 📁 Project Structure

```
lib/
├── components/              # Reusable UI components
│   ├── add_exercise_dialog.dart
│   └── exercise_form.dart
├── models/                  # Data models and Hive adapters
│   ├── workout_session.dart
│   ├── exercise.dart
│   ├── exercise_set.dart
│   └── timer_data.dart
├── viewmodels/             # Business logic and state management
│   ├── workout_session_viewmodel.dart
│   ├── rest_timer_viewmodel.dart
│   └── personal_record_viewmodel.dart
├── views/                  # UI screens and pages
│   ├── main_navigation.dart
│   ├── workouts_view.dart
│   ├── workout_details_view.dart
│   ├── progress_view.dart
│   ├── rest_timer_view.dart
│   └── settings_view.dart
├── services/               # External services and utilities
└── main.dart              # Application entry point
```

## 🧪 Testing

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter test integration_test/
```

### Generate Test Coverage
```bash
flutter test --coverage
open coverage/lcov.info
```

## 🔧 Configuration

### Hive Database
The app uses Hive for local data storage. Database files are stored in:
- **Android**: `/data/data/com.example.gym_tracker/`
- **iOS**: Application Documents directory
- **Desktop**: User's documents folder

### Environment Variables
No environment variables required for basic functionality. Optional configurations:
- Analytics tracking (if implemented)
- Cloud backup services (future feature)

## 📱 Platform Support

- ✅ **Android**: 5.0+ (API level 21+)
- ✅ **iOS**: 12.0+
- ⚠️ **Web**: Basic functionality (limited offline support)
- ⚠️ **Desktop**: Development builds only

## 🔄 CI/CD Pipeline

The repository includes automated GitHub Actions workflows:
- **Continuous Integration**: Automated testing on every push
- **Release Management**: Automatic APK building and GitHub releases
- **Quality Assurance**: Code formatting and analysis

See [`.github/WORKFLOWS.md`](.github/WORKFLOWS.md) for detailed information.

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create your feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes**
4. **Add tests for new functionality**
5. **Run the test suite**
   ```bash
   flutter test
   flutter analyze
   ```
6. **Commit your changes**
   ```bash
   git commit -m 'Add some amazing feature'
   ```
7. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
8. **Open a Pull Request**

### Development Guidelines
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Write tests for new features
- Update documentation for API changes
- Maintain backwards compatibility when possible

## 🐛 Known Issues

- Timer notifications may not work in background on iOS (system limitation)
- Large datasets may impact performance (optimization planned)
- Web version has limited offline functionality

## 🛣️ Roadmap

### Upcoming Features
- [ ] Cloud backup and sync across devices
- [ ] Social features and workout sharing
- [ ] Advanced analytics and AI insights
- [ ] Nutrition tracking integration
- [ ] Wearable device connectivity
- [ ] Dark theme support

### Technical Improvements
- [ ] Performance optimizations for large datasets
- [ ] Enhanced offline capabilities
- [ ] Push notifications for workout reminders
- [ ] Advanced data export formats

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 TheHazeEffect

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 🙏 Acknowledgments

- **Flutter Team**: For the excellent cross-platform framework
- **Hive Contributors**: For the fast, local database solution
- **FL Chart Team**: For beautiful chart implementations
- **Open Source Community**: For the amazing packages used in this project
- **Fitness Community**: For feedback and feature suggestions

## 📞 Support

### Getting Help
- **Documentation**: Check this README and inline code comments
- **Issues**: Report bugs via [GitHub Issues](https://github.com/TheHazeEffect/My-Gym-tracker/issues)
- **Discussions**: Feature requests and general questions in [GitHub Discussions](https://github.com/TheHazeEffect/My-Gym-tracker/discussions)

### Common Questions

**Q: How do I backup my workout data?**
A: Currently, data is stored locally. Cloud backup is planned for future releases.

**Q: Can I export my workout history?**
A: Data export functionality is in development. Currently, data is accessible through the Hive database files.

**Q: Why doesn't the app work offline?**
A: The app is designed to work completely offline. All data is stored locally on your device.

---

*Happy lifting! 💪*

**Made with ❤️ by TheHazeEffect**
