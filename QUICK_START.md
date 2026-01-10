# Pikkar Driver App - Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### 1. Configure API URL

Open `lib/core/constants/api_constants.dart` and update:

```dart
static const String baseUrl = 'http://YOUR_API_URL:5000/api/v1';
static const String socketUrl = 'http://YOUR_API_URL:5000';
```

For local development:
```dart
static const String baseUrl = 'http://localhost:5000/api/v1';
static const String socketUrl = 'http://localhost:5000';
```

For Android emulator accessing localhost:
```dart
static const String baseUrl = 'http://10.0.2.2:5000/api/v1';
static const String socketUrl = 'http://10.0.2.2:5000';
```

### 2. Run the App

```bash
flutter pub get
flutter run
```

### 3. Test Login

Use the API login screen at route: `/login-api`

Or modify splash screen to navigate to API login:
```dart
// In splash_screen.dart
Navigator.pushReplacementNamed(context, AppRoutes.loginAPI);
```

---

## 📖 Common Use Cases

### Authentication

```dart
// Login
final auth = Provider.of<AuthProvider>(context, listen: false);
await auth.login(email: 'driver@example.com', password: 'pass');

// Check if logged in
if (auth.isAuthenticated) {
  print('Logged in as: ${auth.user?.fullName}');
}

// Logout
await auth.logout();
```

### Driver Status

```dart
// Toggle online/offline
final driver = Provider.of<DriverProvider>(context, listen: false);
await driver.toggleOnlineStatus();

// Update location
await driver.updateLocation(longitude: 77.5946, latitude: 12.9716);

// Check status
if (driver.isOnline) {
  print('Driver is online');
}
```

### Ride Management

```dart
final ride = Provider.of<RideProvider>(context, listen: false);

// Listen for ride requests
SocketService().onRideRequest.listen((newRide) {
  // Show dialog or notification
});

// Accept ride
await ride.acceptRide(rideId);

// Update ride status
await ride.markArrived();
await ride.startRide();
await ride.completeRide();

// Get current ride
if (ride.hasActiveRide) {
  print('Current ride: ${ride.currentRide?.id}');
}
```

---

## 🔌 WebSocket

```dart
// Connect (after login)
await SocketService().connect();

// Listen for events
SocketService().onRideRequest.listen((ride) => print('New ride!'));
SocketService().onConnectionStatusChange.listen((connected) {
  print('Socket: ${connected ? "Connected" : "Disconnected"}');
});

// Emit events
SocketService().updateDriverLocation(
  longitude: 77.5946,
  latitude: 12.9716,
);

// Disconnect (on logout)
SocketService().disconnect();
```

---

## 📱 Screen Integration

### Access Provider in Widget

```dart
// With rebuild on change
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Text('User: ${auth.user?.fullName}');
  }
}

// Without rebuild (for callbacks)
void _handleAction(BuildContext context) {
  final auth = Provider.of<AuthProvider>(context, listen: false);
  auth.logout();
}
```

### Using Consumer

```dart
Consumer<RideProvider>(
  builder: (context, rideProvider, child) {
    if (rideProvider.isLoading) {
      return CircularProgressIndicator();
    }
    if (rideProvider.hasActiveRide) {
      return RideWidget(ride: rideProvider.currentRide!);
    }
    return Text('No active ride');
  },
)
```

---

## 🛠️ Troubleshooting

### Can't connect to API

1. Check `ApiConstants.baseUrl` is correct
2. Ensure backend server is running
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. Check network connectivity
5. Check CORS settings on backend

### Tokens not persisting

1. Clear app data and try again
2. Check `flutter_secure_storage` permissions
3. Verify token storage calls are awaited

### WebSocket not connecting

1. Check `ApiConstants.socketUrl` is correct
2. Ensure socket server is running
3. Verify authentication token is valid
4. Check socket server logs for errors

### Provider not updating UI

1. Make sure you're using `Provider.of<T>(context)` (with listen: true)
2. Or use `Consumer<T>` widget
3. Verify `notifyListeners()` is called in provider

---

## 📚 Documentation

- **Full Guide:** `API_INTEGRATION.md`
- **Implementation Details:** `IMPLEMENTATION_SUMMARY.md`
- **Code Examples:** `lib/core/examples/api_integration_examples.dart`

---

## 🎯 API Endpoints Summary

### Auth
- `POST /auth/login` - Login
- `POST /auth/register` - Register
- `GET /auth/me` - Get profile
- `POST /auth/logout` - Logout

### Driver
- `POST /drivers/register` - Register as driver
- `PUT /drivers/location` - Update location
- `PUT /drivers/toggle-online` - Toggle status

### Rides
- `GET /rides` - Get rides
- `PUT /rides/:id/accept` - Accept ride
- `PUT /rides/:id/status` - Update status
- `PUT /rides/:id/cancel` - Cancel ride
- `PUT /rides/:id/rate` - Rate customer

---

## ✅ Quick Checklist

- [ ] Updated API URLs in `api_constants.dart`
- [ ] Run `flutter pub get`
- [ ] Backend server is running
- [ ] Test login with valid credentials
- [ ] Socket connects after login
- [ ] Can toggle driver status
- [ ] Can receive ride requests
- [ ] Can update ride status

---

## 💡 Tips

1. **Always await async operations**
   ```dart
   await authProvider.login(...);  // ✅
   authProvider.login(...);         // ❌
   ```

2. **Check loading states**
   ```dart
   if (provider.isLoading) return CircularProgressIndicator();
   ```

3. **Handle errors**
   ```dart
   if (provider.errorMessage != null) {
     showSnackBar(provider.errorMessage!);
     provider.clearError();
   }
   ```

4. **Connect socket after login**
   ```dart
   if (await auth.login(...)) {
     await SocketService().connect();
   }
   ```

5. **Disconnect socket on logout**
   ```dart
   SocketService().disconnect();
   await auth.logout();
   ```

---

## 🚀 Next Steps

1. Test with your backend
2. Integrate API calls in existing screens
3. Add error handling UI
4. Implement push notifications
5. Add offline support
6. Deploy to production

---

**Need help?** Check the full documentation in `API_INTEGRATION.md`
