# 🏋️‍♂️ Gym Tracker - CI/CD Workflows

This repository includes automated GitHub Actions workflows for continuous integration, testing, and releasing APK builds.

## 📋 Workflow Overview

### 1. **Continuous Integration** (`ci.yml`)
**Triggers**: Push to `main`/`develop`, Pull Requests to `main`
- ✅ Code formatting check
- 🔍 Static analysis with `flutter analyze`
- 🧪 Run all tests with coverage
- 🏗️ Build debug APK and web app
- 📊 Upload coverage reports to Codecov

### 2. **Build and Release** (`build-and-release.yml`)
**Triggers**: Push to `main`, Tags starting with `v*`
- 🧪 Run full test suite
- 🏗️ Build release APK and App Bundle (AAB)
- 📦 Create GitHub release with assets
- 🚀 Upload APK and AAB to release

### 3. **Release** (`release.yml`)
**Triggers**: Tags matching `v*.*.*` pattern
- 📝 Generate changelog from commit history
- 🏗️ Build multiple APK architectures (ARM64, ARM32, x64)
- 📦 Create comprehensive GitHub release
- 🔄 Handle pre-releases (tags with `-` like `v1.0.0-beta`)

### 4. **Manual Release** (`manual-release.yml`)
**Triggers**: Manual workflow dispatch
- 🎛️ Manually trigger releases from GitHub Actions tab
- 📝 Specify custom version and pre-release flag
- 🏗️ Build and release on-demand

## 🚀 How to Use

### Creating a Release

#### Option 1: Automatic Release (Recommended)
1. Create and push a version tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
2. The workflow automatically:
   - Builds release APKs for all architectures
   - Creates a GitHub release
   - Uploads APK and AAB files
   - Generates changelog

#### Option 2: Manual Release
1. Go to GitHub Actions tab
2. Select "Manual Release" workflow
3. Click "Run workflow"
4. Enter version (e.g., `v1.0.1`)
5. Choose if it's a pre-release
6. Click "Run workflow"

### Version Naming Convention
- **Stable releases**: `v1.0.0`, `v1.2.3`
- **Pre-releases**: `v1.0.0-beta`, `v1.0.0-alpha.1`, `v1.0.0-rc.1`

## 📱 Release Assets

Each release includes:
- **APK Files**:
  - `gym-tracker-v1.0.0-arm64.apk` (64-bit ARM - most modern devices)
  - `gym-tracker-v1.0.0-arm32.apk` (32-bit ARM - older devices)
  - `gym-tracker-v1.0.0-x64.apk` (x86_64 - emulators/Intel devices)
- **App Bundle**:
  - `gym-tracker-v1.0.0.aab` (for Google Play Store)

## 🔧 Setup Requirements

### GitHub Repository Settings
1. **Actions**: Enable GitHub Actions (usually enabled by default)
2. **Permissions**: Workflows have `contents: write` permission to create releases

### Secrets (Optional)
Currently no secrets are required, but you may want to add:
- `CODECOV_TOKEN`: For private repositories (coverage reporting)
- `SLACK_WEBHOOK`: For notifications
- `KEYSTORE_*`: For signed APK releases

## 🐛 Troubleshooting

### Common Issues

**Build fails on dependencies**:
- Check `pubspec.yaml` for version conflicts
- Ensure Flutter version compatibility

**Tests fail**:
- Run `flutter test` locally first
- Check test files for async/await issues

**APK build fails**:
- Verify Android configuration in `android/` directory
- Check for missing permissions or configurations

**Release creation fails**:
- Ensure tag follows `v*.*.*` pattern
- Check repository permissions

## 📊 Monitoring

- **Build Status**: Check the Actions tab for workflow results
- **Coverage**: View coverage reports on Codecov (if configured)
- **Releases**: Monitor download stats in the Releases section

## 🔄 Workflow Updates

To modify workflows:
1. Edit files in `.github/workflows/`
2. Test changes on feature branches
3. Monitor workflow runs for issues

---

## 📞 Support

For issues with the workflows:
1. Check the Actions logs for detailed error messages
2. Verify Flutter and Dart configurations
3. Open an issue if problems persist
