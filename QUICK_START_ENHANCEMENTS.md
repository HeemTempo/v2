# Quick Start - UI Enhancements

## ✅ What's Already Done:

1. **Enhanced Bottom Sheet** - `lib/widget/space_detail_bottom_sheet.dart`
2. **Stats Service** - `lib/service/stats_service.dart`
3. **Lottie Package** - Added to pubspec.yaml
4. **Placeholder Lottie** - `assets/lottie/loading.json`

## 🚀 Quick Implementation (5 Steps):

### Step 1: Download Real Lottie Animations (2 minutes)

Visit https://lottiefiles.com and download these FREE animations:

1. Search "loading spinner" → Download as JSON → Rename to `loading.json`
2. Search "success checkmark" → Download as JSON → Rename to `success.json`
3. Search "empty state" → Download as JSON → Rename to `empty.json`
4. Search "celebration confetti" → Download as JSON → Rename to `celebration.json`

Place all in: `assets/lottie/`

### Step 2: Run Flutter Pub Get
```bash
cd v2
flutter pub get
```

### Step 3: Integrate Bottom Sheet in Map Screen

Open `lib/screens/map_screen.dart` and add at the top:
```dart
import '../widget/space_detail_bottom_sheet.dart';
```

Find where markers are tapped and replace the old bottom sheet with:
```dart
void _showSpaceDetails(Map<String, dynamic> space) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SpaceDetailBottomSheet(
      space: space,
      onBookNow: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          '/book',
          arguments: {
            'spaceId': space['id'],
            'spaceName': space['name'],
          },
        );
      },
      onReportIssue: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          '/report-issue',
          arguments: {
            'spaceName': space['name'],
            'latitude': space['latitude'],
            'longitude': space['longitude'],
          },
        );
      },
    ),
  );
}
```

### Step 4: Make Home Stats Dynamic

Open `lib/screens/home_page.dart` and add at the top:
```dart
import '../service/stats_service.dart';
```

In `_HomePageState` class, add:
```dart
Map<String, int> _stats = {'openSpaces': 0, 'activeReports': 0, 'bookings': 0};
```

In `initState()`, add:
```dart
_fetchStats();
```

Add this method:
```dart
Future<void> _fetchStats() async {
  final stats = await StatsService.fetchStats();
  if (mounted) {
    setState(() => _stats = stats);
  }
}
```

In `_buildQuickStats` method, replace hardcoded values:
```dart
// Change from:
_buildStatCard(locale.openSpaces, '47', ...)

// To:
_buildStatCard(locale.openSpaces, '${_stats['openSpaces']}', ...)
_buildStatCard(locale.activeReports, '${_stats['activeReports']}', ...)
_buildStatCard(locale.bookings, '${_stats['bookings']}', ...)
```

### Step 5: Add Lottie Animations

#### In Loading States:
Replace `CircularProgressIndicator()` with:
```dart
import 'package:lottie/lottie.dart';

Lottie.asset(
  'assets/lottie/loading.json',
  width: 100,
  height: 100,
)
```

#### In Empty States:
Replace empty messages with:
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Lottie.asset(
      'assets/lottie/empty.json',
      height: 200,
    ),
    const SizedBox(height: 16),
    Text('No items found'),
  ],
)
```

#### In Success Dialogs:
Add to QuickAlert success:
```dart
// In report_screen.dart and book_openspace.dart
// Before showing success alert, add:
Lottie.asset(
  'assets/lottie/success.json',
  repeat: false,
  width: 150,
  height: 150,
)
```

## 🎯 Backend API (Django)

Add this to your Django backend (`views.py`):

```python
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import OpenSpace, Report, Booking

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_stats(request):
    """Get dashboard statistics"""
    return Response({
        'open_spaces': OpenSpace.objects.filter(is_active=True).count(),
        'active_reports': Report.objects.filter(
            user=request.user,
            status__in=['pending', 'in_progress']
        ).count(),
        'bookings': Booking.objects.filter(user=request.user).count(),
    })
```

Add to `urls.py`:
```python
path('api/v1/stats/', views.get_stats, name='stats'),
```

## 🧪 Testing:

1. **Bottom Sheet**: Tap any marker on map → Should show detailed info
2. **Book Now**: Tap "Book Now" → Should navigate to booking form
3. **Stats**: Open home screen → Numbers should load from API
4. **Animations**: Check loading states → Should show Lottie animations
5. **Offline**: Turn off internet → Stats should show default values

## 📱 Expected Results:

- ✅ Beautiful animated bottom sheet on map
- ✅ Smooth Lottie animations everywhere
- ✅ Real-time stats from backend
- ✅ Professional UI matching government standards
- ✅ Engaging animations for Tanzanian users

## 🎨 Optional Enhancements:

### Add Shimmer Loading:
```yaml
# In pubspec.yaml:
dependencies:
  shimmer: ^3.0.0
```

```dart
import 'package:shimmer/shimmer.dart';

Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Container(
    height: 100,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### Add Animated Counter:
```dart
import 'package:animated_text_kit/animated_text_kit.dart';

AnimatedTextKit(
  animatedTexts: [
    TypewriterAnimatedText(
      '${_stats['openSpaces']}',
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      speed: Duration(milliseconds: 100),
    ),
  ],
  totalRepeatCount: 1,
)
```

## 🚨 Common Issues:

**Issue**: Lottie not showing
**Fix**: Make sure files are in `assets/lottie/` and run `flutter pub get`

**Issue**: Stats showing 0
**Fix**: Check backend API is running and accessible

**Issue**: Bottom sheet not showing
**Fix**: Ensure space data has required fields (id, name, district)

## ✅ Completion Checklist:

- [ ] Downloaded Lottie animations
- [ ] Ran `flutter pub get`
- [ ] Integrated bottom sheet in map
- [ ] Made stats dynamic
- [ ] Added Lottie to loading states
- [ ] Added Lottie to empty states
- [ ] Added backend stats API
- [ ] Tested on device
- [ ] Verified animations smooth
- [ ] Checked offline mode works
