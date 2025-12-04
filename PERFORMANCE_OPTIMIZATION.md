# App Performance Optimization Guide

## Common Causes of App Crashes/Freezing

### 1. Heavy Operations on Main Thread
- Large image loading
- Database queries
- Network requests
- Complex calculations

### 2. Memory Leaks
- Not disposing controllers
- Unclosed streams
- Retained references

### 3. Infinite Loops or Recursion
- Provider circular dependencies
- Rebuild loops

## Quick Fixes Applied

### 1. Add Timeouts to Network Requests
All API calls should have timeouts to prevent indefinite waiting.

### 2. Optimize Image Loading
Use cached network images and compress images.

### 3. Add Error Boundaries
Catch and handle errors gracefully.

### 4. Lazy Loading
Load data only when needed.

### 5. Debounce User Actions
Prevent multiple rapid submissions.

## Debugging Crashes

### Check Logs
```bash
flutter run --release
# or
adb logcat | grep flutter
```

### Enable Performance Overlay
```dart
MaterialApp(
  showPerformanceOverlay: true,
  // ...
)
```

### Profile Mode
```bash
flutter run --profile
```

## Memory Management

### Always Dispose Controllers
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### Use const Widgets
```dart
const Text('Hello') // Better than Text('Hello')
```

### Limit List Items
Use ListView.builder with pagination instead of loading all items.
