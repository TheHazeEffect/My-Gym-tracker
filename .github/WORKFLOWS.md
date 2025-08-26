# 🏋️‍♂️ Gym Tracker - CI/CD Workflows

This repository includes an automated GitHub Actions workflow for continuous integration, testing, and releasing APK builds.

## 📋 Current Workflow Overview

### **Flutter CI/CD** (`build-and-release.yml`)
**Triggers**: 
- Push to `main` branch
- Tags matching `v*.*.*` pattern

**Process Flow**:
1. **Build Job**:
   - ✅ Checkout source code
   - 🛠️ Setup Flutter (version 3.35.1, stable channel)
   - 📦 Install dependencies with `flutter pub get`
   - 🧪 Run all tests with `flutter test`
   - 🏗️ Build release APK with automatic version bumping
   - � Upload APK as build artifact

2. **Release Job** (only for tags):
   - � Download built APK artifact
   - � Create GitHub release with APK attachment

## 🚀 How to Use

### Creating a Release

#### Option 1: Automatic Tag-based Release (Recommended)
1. Create and push a version tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. The workflow automatically:
   - Runs the full test suite
   - Builds release APK with auto-versioning
   - Creates a GitHub release
   - Attaches the APK to the release

#### Option 2: Development Build (Main Branch)
1. Push changes to the `main` branch:
   ```bash
   git push origin main
   ```
2. The workflow will:
   - Run tests to ensure code quality
   - Build APK with incremental build numbers
   - Upload APK as artifact (available for 90 days)

### Version Management
- **Base Version**: Defined in `pubspec.yaml` (e.g., `1.0.0+1`)
- **Automatic Build Numbers**: Uses GitHub run number for unique builds
- **Tag Releases**: Use semantic versioning (`v1.0.0`, `v1.1.0`, `v2.0.0`)

## 🏗️ Build Process

### Automatic Version Bumping
The workflow automatically manages versions:
```yaml
VERSION_NAME: Extracted from pubspec.yaml (before '+')
BUILD_NUMBER: GitHub run number
FINAL_VERSION: $VERSION_NAME+$BUILD_NUMBER
```

### Build Configuration
- **Flutter Version**: 3.35.1 (stable channel)
- **Build Type**: Release APK (`--release`)
- **Target**: Universal APK (compatible with all Android architectures)

## 📱 Release Assets

Each tagged release includes:
- **Universal APK**: `app-release.apk` - Compatible with all Android devices
- **Source Code**: Automatic GitHub archive (ZIP/TAR)
- **Build Metadata**: Version information and build details

### APK Details
- **Type**: Universal APK (single file for all architectures)
- **Size**: Optimized release build
- **Compatibility**: Android 5.0+ (API level 21+)
- **Installation**: Direct APK installation on Android devices

## 🔧 Setup Requirements

### Repository Configuration
- **GitHub Actions**: Enabled by default
- **Permissions**: Workflows have `contents: write` for releases
- **Flutter Version**: Fixed at 3.35.1 (stable channel)

### Required Files
- `pubspec.yaml`: Must contain version in format `x.y.z+build`
- Valid Flutter project structure
- Test files (workflow runs `flutter test`)

### Optional Enhancements
Consider adding these secrets for advanced features:
- `KEYSTORE_*`: For APK signing
- `CODECOV_TOKEN`: For coverage reporting
- `SLACK_WEBHOOK`: For build notifications

## 🐛 Troubleshooting

### Common Build Issues

**❌ "Flutter test failed"**
```bash
# Run tests locally first
flutter test
# Fix any failing tests before pushing
```

**❌ "Dependencies resolution failed"**
```bash
# Clean and reinstall dependencies
flutter clean
flutter pub get
```

**❌ "APK build failed"**
- Check `android/app/build.gradle` configuration
- Verify minimum SDK version compatibility
- Review build logs in Actions tab for specific errors

**❌ "Release creation failed"**
- Ensure tag follows `v*.*.*` pattern exactly (e.g., `v1.0.0`)
- Check repository permissions
- Verify no duplicate releases exist

### Workflow Debugging

1. **Check Actions Logs**:
   - Navigate to Actions tab → Select failed run → View detailed logs
   
2. **Test Build Locally**:
   ```bash
   flutter clean
   flutter pub get
   flutter test
   flutter build apk --release
   ```

3. **Validate Configuration**:
   ```bash
   flutter doctor -v
   flutter --version
   ```

## 📊 Monitoring

### Build Artifacts
- **Main Branch Builds**: Available as artifacts for 90 days
- **Tagged Releases**: Permanently available in Releases section
- **Build History**: View all runs in Actions tab

### Key Metrics to Monitor
- **Build Success Rate**: Track in Actions dashboard
- **Test Coverage**: Monitor test results
- **Build Duration**: Optimize if builds become slow
- **APK Size**: Track app size over time

## 🔄 Workflow Maintenance

### Regular Updates
- **Flutter Version**: Update `flutter-version` in workflow when new stable releases are available
- **GitHub Actions**: Keep action versions updated (currently using @v4, @v2)
- **Dependencies**: Monitor `pubspec.yaml` for outdated packages

### Testing Changes
1. Create feature branch with workflow modifications
2. Push changes to test workflow behavior
3. Merge to main only after successful testing

### Version Management in `pubspec.yaml`
```yaml
# Current format requirement
version: 1.0.0+1
#        ^     ^
#        |     └── Build number (auto-incremented)
#        └── Version name (manually updated)
```

---

## 📞 Getting Help

### Workflow Issues
1. **Check Actions Logs**: Detailed error messages available in GitHub Actions tab
2. **Compare Successful Runs**: Look at previous successful builds for differences
3. **Test Locally**: Reproduce the build process on your development machine
4. **GitHub Documentation**: Reference [GitHub Actions docs](https://docs.github.com/en/actions)

### Flutter Build Issues
1. **Verify Setup**: Run `flutter doctor` to check your development environment
2. **Clean Build**: Use `flutter clean && flutter pub get` to reset build cache
3. **Version Check**: Ensure Flutter version matches workflow (3.35.1)

### Release Problems
1. **Tag Format**: Must follow `v*.*.*` pattern (e.g., `v1.0.0`, not `1.0.0`)
2. **Permissions**: Repository needs Actions enabled and write permissions
3. **Duplicate Check**: Ensure no existing release with same tag

---

*Last updated: August 2025*
*Workflow file: `.github/workflows/build-and-release.yml`*
