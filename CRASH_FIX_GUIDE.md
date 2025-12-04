# App Crash Fix Guide

## Issue: App Not Responding (ANR)

### Root Causes
1. Heavy operations on main thread during initialization
2. Database queries blocking UI
3. Network requests without timeout
4. Provider initialization issues

## Fixes Applied

### 1. Report Screen Crash Fix
**Problem**: Sync operation blocking UI on screen load
**Solution**: Deferred sync using `addPostFrameCallback`

```dart
// Before (BLOCKS UI)
void initState() {
  super.initState();
  context.read<ReportProvider>().syncPendingReports(); // BLOCKS!
}

// After (NON-BLOCKING)
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      context.read<ReportProvider>().syncPendingReports();
    }
  });
}
```

### 2. Home Page ANR Fix
**Problem**: Data fetching blocking app startup
**Solution**: Deferred data loading

```dart
// Defer heavy operations
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (mounted) {
    _fetchQuickStats();
    _fetchRecentActivities();
  }
});
```

### 3. Error Boundaries
Added try-catch blocks to prevent complete crashes

## Testing Steps

### 1. Clean Build
```bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

### 2. Test Scenarios
- ✅ Open app (should load quickly)
- ✅ Navigate to Report screen (should not freeze)
- ✅ Submit report (should handle errors)
- ✅ Switch between screens rapidly
- ✅ Test with slow network
- ✅ Test offline mode

### 3. Monitor Performance
```bash
# Run in profile mode
flutter run --profile

# Watch for:
# - Frame drops
# - Long operations (>16ms)
# - Memory leaks
```

## Additional Optimizations

### 1. Reduce Image Sizes
```bash
# Compress images in assets/images/
# Use tools like TinyPNG or ImageOptim
```

### 2. Enable R8 Shrinking
Already enabled in `build.gradle.kts`:
```kotlin
isMinifyEnabled = true
isShrinkResources = true
```

### 3. Lazy Load Data
- Load data only when needed
- Use pagination for lists
- Cache frequently accessed data

## Common ANR Patterns to Avoid

### ❌ DON'T
```dart
void initState() {
  super.initState();
  // Heavy operation blocks UI
  var data = fetchDataFromDatabase(); // BLOCKS!
  processData(data); // BLOCKS!
}
```

### ✅ DO
```dart
void initState() {
  super.initState();
  // Defer to next frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData();
  });
}

Future<void> _loadData() async {
  try {
    var data = await fetchDataFromDatabase();
    if (mounted) {
      setState(() => _data = data);
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
}
```

## Monitoring Tools

### 1. Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### 2. Android Profiler
- Open Android Studio
- Run app
- View > Tool Windows > Profiler
- Monitor CPU, Memory, Network

### 3. Logcat
```bash
adb logcat | grep -i "flutter\|crash\|anr"
```

## Performance Targets

- App startup: < 2 seconds
- Screen navigation: < 300ms
- Data loading: < 1 second
- Frame rate: 60 FPS (16ms per frame)

## If App Still Crashes

1. Check logcat for stack trace
2. Identify the exact line causing crash
3. Add try-catch around that operation
4. Add timeout to async operations
5. Test on different devices
