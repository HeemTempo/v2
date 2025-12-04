# Production Build Instructions

## Build Optimized APK (Recommended)

### 1. Build Release APK with Split ABIs (Smallest Size)
```bash
flutter build apk --release --split-per-abi
```
This creates 3 separate APKs for different architectures:
- `app-armeabi-v7a-release.apk` (~20-25 MB) - For older 32-bit devices
- `app-arm64-v8a-release.apk` (~25-30 MB) - For modern 64-bit devices (most common)
- `app-x86_64-release.apk` (~30-35 MB) - For emulators/tablets

**Use `app-arm64-v8a-release.apk` for most Android devices (2019+)**

### 2. Build Single Universal APK (Larger but works on all devices)
```bash
flutter build apk --release
```
Output: `app-release.apk` (~70-75 MB)

### 3. Build App Bundle for Google Play Store (Best Compression)
```bash
flutter build appbundle --release
```
Output: `app-release.aab` (~40-50 MB)
Google Play automatically optimizes downloads per device (~25-30 MB per install)

## Additional Size Optimization

### 1. Remove Unused Resources
```bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi --tree-shake-icons
```

### 2. Analyze APK Size
```bash
flutter build apk --release --analyze-size
```

## Build Locations
- APKs: `build/app/outputs/flutter-apk/`
- AAB: `build/app/outputs/bundle/release/`

## Recommended for Distribution
- **Testing**: Use split APK (`app-arm64-v8a-release.apk`)
- **Play Store**: Use App Bundle (`app-release.aab`)
- **Direct Download**: Use universal APK (`app-release.apk`)
