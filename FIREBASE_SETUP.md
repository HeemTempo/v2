# Firebase Push Notifications Setup Guide

## Step 1: Create Firebase Project (5 minutes)

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Enter project name: "Kinondoni App"
4. Disable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click Android icon
2. Enter package name: `com.example.openspace_mobile_app`
3. Download `google-services.json`
4. Place file in: `android/app/google-services.json`

## Step 3: Configure Android

### File: `android/build.gradle.kts`
Add at the top:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

### File: `android/app/build.gradle.kts`
Add at the top (after plugins):
```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") version "2.1.0"
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this line
}
```

Add in `android` block:
```kotlin
android {
    defaultConfig {
        minSdk = 21 // Firebase requires min SDK 21
    }
}
```

## Step 4: Add iOS App (Optional)

1. In Firebase Console, click iOS icon
2. Enter bundle ID: `com.example.openspaceMobileApp`
3. Download `GoogleService-Info.plist`
4. Place in: `ios/Runner/GoogleService-Info.plist`

## Step 5: Run Flutter Commands

```bash
cd v2
flutter pub get
flutter clean
flutter run
```

## Step 6: Test Push Notifications

### From Firebase Console:
1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Click "Send test message"
5. Enter FCM token (check console logs)
6. Click "Test"

### From Your Backend:
```python
# Install: pip install firebase-admin

import firebase_admin
from firebase_admin import credentials, messaging

# Initialize Firebase Admin
cred = credentials.Certificate('path/to/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

# Send notification
def send_push_notification(token, title, body, data=None):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        token=token,
    )
    
    response = messaging.send(message)
    print(f'Successfully sent message: {response}')

# Example usage
send_push_notification(
    token='USER_FCM_TOKEN',
    title='Report Updated',
    body='Your report has been reviewed',
    data={'type': 'report', 'id': '123'}
)
```

## Step 7: Save FCM Token to Backend

### In Flutter (already implemented):
```dart
// Token is automatically retrieved in PushNotificationService
// Send it to your backend:

final token = await PushNotificationService().getToken();
// POST to your API: /api/v1/users/fcm-token/
```

### In Django Backend:
```python
# models.py
class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    fcm_token = models.CharField(max_length=255, blank=True, null=True)

# views.py
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def save_fcm_token(request):
    token = request.data.get('token')
    profile, created = UserProfile.objects.get_or_create(user=request.user)
    profile.fcm_token = token
    profile.save()
    return Response({'status': 'success'})

# urls.py
path('api/v1/users/fcm-token/', views.save_fcm_token),
```

## Notification Types

### 1. Report Status Update
```python
send_push_notification(
    token=user.profile.fcm_token,
    title='Report Status Updated',
    body=f'Your report #{report.id} is now {report.status}',
    data={'type': 'report', 'id': str(report.id)}
)
```

### 2. Booking Confirmation
```python
send_push_notification(
    token=user.profile.fcm_token,
    title='Booking Confirmed',
    body=f'Your booking for {space.name} is confirmed',
    data={'type': 'booking', 'id': str(booking.id)}
)
```

### 3. Sync Complete
```python
send_push_notification(
    token=user.profile.fcm_token,
    title='Sync Complete',
    body='Your offline data has been synced successfully',
    data={'type': 'sync'}
)
```

## Topic Subscriptions

Subscribe users to topics for broadcast messages:

```dart
// Subscribe to all users topic
await PushNotificationService().subscribeToTopic('all_users');

// Subscribe to district-specific topic
await PushNotificationService().subscribeToTopic('kinondoni_district');
```

Send to topic from backend:
```python
message = messaging.Message(
    notification=messaging.Notification(
        title='New Open Space Available',
        body='Check out the new park in Kinondoni',
    ),
    topic='kinondoni_district',
)
messaging.send(message)
```

## Troubleshooting

### Issue: "Default FirebaseApp is not initialized"
**Fix**: Ensure `Firebase.initializeApp()` is called in main()

### Issue: "google-services.json not found"
**Fix**: Place file in `android/app/` directory

### Issue: Notifications not received
**Fix**: 
1. Check FCM token is valid
2. Verify app has notification permissions
3. Test with Firebase Console first
4. Check backend is sending correct format

### Issue: Background notifications not working
**Fix**: Ensure background handler is registered before runApp()

## Testing Checklist

- [ ] Firebase project created
- [ ] google-services.json added
- [ ] Android build.gradle configured
- [ ] Flutter pub get completed
- [ ] App runs without errors
- [ ] FCM token printed in console
- [ ] Test notification from Firebase Console works
- [ ] Foreground notifications show
- [ ] Background notifications show
- [ ] Notification tap opens app
- [ ] Token saved to backend

## Production Considerations

1. **Security**: Never commit google-services.json to public repos
2. **Token Refresh**: Handle token refresh in app
3. **Unsubscribe**: Unsubscribe from topics on logout
4. **Rate Limiting**: Don't spam users with notifications
5. **Localization**: Send notifications in user's language
6. **Analytics**: Track notification open rates

## Next Steps

1. Implement notification handling in app
2. Add deep linking for notification taps
3. Create notification preferences screen
4. Add notification history
5. Implement notification badges
