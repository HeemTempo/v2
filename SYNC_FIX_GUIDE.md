# Sync Fix Guide - Reports Not Syncing

## Problem
Reports remain in "pending" state and don't sync to backend when online.

## Root Causes Fixed

### 1. ✅ Sync Service Enhanced
- Added sync-in-progress flag to prevent duplicate syncs
- Added initial connectivity check on app start
- Better error handling with retry logic
- Improved logging for debugging

### 2. ✅ Connectivity Detection Improved
- Handles both single and list connectivity results
- Checks actual connectivity, not just network state
- Triggers sync immediately when connection detected

## How to Test Sync

### Test 1: Manual Sync
```dart
// In any screen, trigger manual sync:
import '../core/sync/sync_service.dart';

ElevatedButton(
  onPressed: () async {
    await SyncService().syncNow();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sync triggered')),
    );
  },
  child: Text('Sync Now'),
)
```

### Test 2: Automatic Sync on Connectivity
1. Turn OFF WiFi/Data
2. Submit a report
3. Check console: Should see "Saved offline"
4. Turn ON WiFi/Data
5. Check console: Should see "[SyncService] Connection detected, triggering sync..."
6. Wait 2-3 seconds
7. Check console: Should see "✓ All offline data synced successfully"

### Test 3: Check Pending Reports
```dart
// Check what's pending:
final pending = await ReportRepository(localService: ReportLocal()).getPendingReports();
print('Pending reports: ${pending.length}');
for (var report in pending) {
  print('- ${report.id}: ${report.status}');
}
```

## Debug Sync Issues

### Enable Verbose Logging

Add this to see detailed sync logs:

```dart
// In sync_service.dart, add more logs:
Future<void> _syncAll() async {
  print('[SyncService] === SYNC START ===');
  print('[SyncService] Is syncing: $_isSyncing');
  
  if (_isSyncing) {
    print('[SyncService] Sync already in progress, skipping...');
    return;
  }

  _isSyncing = true;
  
  try {
    // Get pending counts
    final pendingReports = await _reportRepo.getPendingReports();
    final pendingBookings = await _bookingRepo.getPendingBookings();
    
    print('[SyncService] Found ${pendingReports.length} pending reports');
    print('[SyncService] Found ${pendingBookings.length} pending bookings');
    
    if (pendingReports.isEmpty && pendingBookings.isEmpty) {
      print('[SyncService] Nothing to sync');
      return;
    }
    
    // Sync reports
    print('[SyncService] Syncing reports...');
    await _reportRepo.syncPendingReports();
    print('[SyncService] ✓ Reports synced');
    
    // Sync bookings
    print('[SyncService] Syncing bookings...');
    await _bookingRepo.syncPendingBookings();
    print('[SyncService] ✓ Bookings synced');
    
    print('[SyncService] === SYNC COMPLETE ===');
  } catch (e, stackTrace) {
    print('[SyncService] === SYNC ERROR ===');
    print('[SyncService] Error: $e');
    print('[SyncService] Stack: $stackTrace');
  } finally {
    _isSyncing = false;
  }
}
```

### Check Backend API

Test your backend endpoint:
```bash
# Test report creation
curl -X POST http://192.168.100.110:8001/api/v1/reports/ \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Test report",
    "email": "test@example.com",
    "space_name": "Test Space",
    "latitude": -6.7924,
    "longitude": 39.2083
  }'
```

### Common Issues & Fixes

#### Issue 1: "Sync triggered but nothing happens"
**Cause**: No pending items or already syncing
**Fix**: Check pending count first
```dart
final pending = await reportRepo.getPendingReports();
print('Pending: ${pending.length}');
```

#### Issue 2: "Network error during sync"
**Cause**: Backend not reachable
**Fix**: 
1. Check backend is running
2. Verify IP address is correct
3. Test with curl/Postman first

#### Issue 3: "Reports stay pending after sync"
**Cause**: Sync failed but no error shown
**Fix**: Check backend response
```dart
// In report_repository.dart, add logging:
print('Sync response: $response');
print('Status code: ${response.statusCode}');
```

#### Issue 4: "Sync happens but reports not removed"
**Cause**: Status not updated in local DB
**Fix**: Ensure status is updated after successful sync
```dart
// After successful sync:
await localService.updateReportStatus(report.id, 'submitted');
```

## Force Sync All Pending Items

Create a debug screen to manually trigger sync:

```dart
class DebugSyncScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug Sync')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () async {
              final reportRepo = ReportRepository(localService: ReportLocal());
              final pending = await reportRepo.getPendingReports();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${pending.length} pending reports')),
              );
              
              for (var report in pending) {
                print('Pending: ${report.id} - ${report.description}');
              }
            },
            child: Text('Check Pending Reports'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await SyncService().syncNow();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sync triggered')),
              );
            },
            child: Text('Force Sync Now'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final db = await LocalDb.getDb();
              final reports = await db.query('reports');
              
              print('=== ALL REPORTS IN DB ===');
              for (var report in reports) {
                print('${report['id']}: ${report['status']}');
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${reports.length} total reports')),
              );
            },
            child: Text('Show All Reports in DB'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final result = await Connectivity().checkConnectivity();
              final isOnline = result != ConnectivityResult.none;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isOnline ? 'ONLINE' : 'OFFLINE'),
                  backgroundColor: isOnline ? Colors.green : Colors.red,
                ),
              );
            },
            child: Text('Check Connectivity'),
          ),
        ],
      ),
    );
  }
}
```

## Monitoring Sync Status

Add a sync status indicator to your app:

```dart
class SyncStatusIndicator extends StatefulWidget {
  @override
  _SyncStatusIndicatorState createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  bool _isSyncing = false;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _checkPending();
    
    // Check every 10 seconds
    Timer.periodic(Duration(seconds: 10), (_) => _checkPending());
  }

  Future<void> _checkPending() async {
    final reportRepo = ReportRepository(localService: ReportLocal());
    final bookingRepo = BookingRepository();
    
    final reports = await reportRepo.getPendingReports();
    final bookings = await bookingRepo.getPendingBookings();
    
    if (mounted) {
      setState(() {
        _pendingCount = reports.length + bookings.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingCount == 0) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync, size: 16, color: Colors.white),
          SizedBox(width: 4),
          Text(
            '$_pendingCount pending',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
```

## Expected Console Output (Successful Sync)

```
[SyncService] Initializing sync service...
[SyncService] Initial connectivity check - syncing...
[SyncService] Starting sync of offline data...
[SyncService] Syncing reports...
Syncing 2 pending reports...
✓ Successfully synced report: local_1234567890
✓ Successfully synced report: local_1234567891
Sync complete: 2 succeeded, 0 failed
[SyncService] Syncing bookings...
Syncing 1 pending bookings...
✓ Successfully synced booking: local_1234567892
Sync complete: 1 succeeded, 0 failed
[SyncService] ✓ All offline data synced successfully
```

## Quick Fix Checklist

- [x] Enhanced SyncService with better error handling
- [x] Added sync-in-progress flag
- [x] Added initial connectivity check
- [x] Improved logging
- [x] Added manual sync trigger
- [ ] Test with real device (not emulator)
- [ ] Verify backend API is accessible
- [ ] Check console logs during sync
- [ ] Confirm reports removed from pending after sync

## Still Not Working?

1. Check backend logs for errors
2. Verify token is valid
3. Test API with Postman
4. Enable verbose logging
5. Use debug sync screen
6. Check network permissions in AndroidManifest.xml
