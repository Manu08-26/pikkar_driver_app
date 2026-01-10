# Pikkar Driver App - API Integration Guide

## Overview

This document provides a complete guide on how to use the Pikkar API integration in the driver app.

## Architecture

The API integration follows a clean architecture pattern:

```
lib/
├── core/
│   ├── models/           # Data models
│   ├── services/         # API services
│   ├── providers/        # State management (Provider)
│   ├── constants/        # API endpoints and constants
│   └── examples/         # Usage examples
```

## Setup

### 1. Dependencies

The following dependencies are already added to `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0                      # HTTP client
  socket_io_client: ^2.0.3+1       # WebSocket client
  provider: ^6.1.1                 # State management
  flutter_secure_storage: ^9.0.0   # Secure token storage
```

Run `flutter pub get` to install dependencies.

### 2. API Configuration

Update the base URL in `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:5000/api/v1'; // Change to your API URL
  static const String socketUrl = 'http://localhost:5000';       // Change to your Socket URL
}
```

For production, use your production API URL.

## Core Components

### 1. Models

Located in `lib/core/models/`:

- **`user_model.dart`** - User data model
- **`driver_model.dart`** - Driver profile and vehicle data
- **`ride_model.dart`** - Ride request and tracking data
- **`auth_tokens.dart`** - Authentication tokens
- **`api_response.dart`** - Generic API response wrapper

### 2. Services

Located in `lib/core/services/`:

- **`api_client.dart`** - Core HTTP client with interceptors
- **`auth_service.dart`** - Authentication APIs (login, register, logout)
- **`driver_service.dart`** - Driver-specific APIs (status, location)
- **`ride_service.dart`** - Ride management APIs (accept, start, complete)
- **`socket_service.dart`** - WebSocket for real-time updates
- **`token_storage_service.dart`** - Secure token storage

### 3. Providers

Located in `lib/core/providers/`:

- **`auth_provider.dart`** - Authentication state management
- **`driver_provider.dart`** - Driver profile and status
- **`ride_provider.dart`** - Current and historical rides

## Usage Guide

### Authentication

#### Login

```dart
import 'package:provider/provider.dart';
import 'package:pikkar_driver_app/core/providers/auth_provider.dart';

// In your widget
final authProvider = Provider.of<AuthProvider>(context, listen: false);

final success = await authProvider.login(
  email: 'driver@example.com',
  password: 'password123',
);

if (success) {
  // Login successful
  // Connect to WebSocket
  await SocketService().connect();
  
  // Navigate to home
  Navigator.pushReplacementNamed(context, AppRoutes.home);
} else {
  // Show error
  print('Error: ${authProvider.errorMessage}');
}
```

#### Logout

```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);

// Disconnect socket first
SocketService().disconnect();

// Logout
await authProvider.logout();

// Navigate to login
Navigator.pushReplacementNamed(context, AppRoutes.login);
```

#### Access Current User

```dart
// Listen to changes
final authProvider = Provider.of<AuthProvider>(context);

if (authProvider.isAuthenticated) {
  print('User: ${authProvider.user?.fullName}');
  print('Email: ${authProvider.user?.email}');
  print('Role: ${authProvider.user?.role}');
}
```

### Driver Management

#### Toggle Online Status

```dart
final driverProvider = Provider.of<DriverProvider>(context, listen: false);

final success = await driverProvider.toggleOnlineStatus();

if (success) {
  print('Online: ${driverProvider.isOnline}');
}
```

#### Update Location

```dart
import 'package:geolocator/geolocator.dart';

final driverProvider = Provider.of<DriverProvider>(context, listen: false);
final position = await Geolocator.getCurrentPosition();

// Update via API
await driverProvider.updateLocation(
  longitude: position.longitude,
  latitude: position.latitude,
);

// Also update via socket for real-time tracking
if (SocketService().isConnected) {
  SocketService().updateDriverLocation(
    longitude: position.longitude,
    latitude: position.latitude,
  );
}
```

#### Register as Driver

```dart
final driverProvider = Provider.of<DriverProvider>(context, listen: false);

final success = await driverProvider.registerDriver(
  licenseNumber: 'DL1234567890',
  licenseExpiry: '2026-12-31',
  vehicleType: 'sedan',
  vehicleModel: 'Camry',
  vehicleMake: 'Toyota',
  vehicleYear: 2022,
  vehicleColor: 'Black',
  vehicleNumber: 'KA01AB1234',
);
```

### Ride Management

#### Listen for Ride Requests

```dart
@override
void initState() {
  super.initState();
  
  // Listen for new ride requests via WebSocket
  SocketService().onRideRequest.listen((ride) {
    if (mounted) {
      _showRideRequestDialog(ride);
    }
  });
}

void _showRideRequestDialog(RideModel ride) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('New Ride Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pickup: ${ride.pickupLocation.address}'),
          Text('Drop: ${ride.dropoffLocation.address}'),
          Text('Distance: ${ride.distance} km'),
          Text('Fare: ₹${ride.estimatedFare}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Reject'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _acceptRide(ride.id);
          },
          child: const Text('Accept'),
        ),
      ],
    ),
  );
}
```

#### Accept Ride

```dart
final rideProvider = Provider.of<RideProvider>(context, listen: false);

final success = await rideProvider.acceptRide(rideId);

if (success) {
  // Navigate to ride detail screen
  Navigator.pushNamed(context, AppRoutes.rideDetail);
}
```

#### Update Ride Status

```dart
final rideProvider = Provider.of<RideProvider>(context, listen: false);

// Mark as arrived at pickup location
await rideProvider.markArrived();

// Start the ride (customer entered vehicle)
await rideProvider.startRide();

// Complete the ride
await rideProvider.completeRide();
```

#### Cancel Ride

```dart
final rideProvider = Provider.of<RideProvider>(context, listen: false);

await rideProvider.cancelRide('Customer requested cancellation');
```

#### Access Current Ride

```dart
// Listen to changes
final rideProvider = Provider.of<RideProvider>(context);

if (rideProvider.hasActiveRide) {
  final ride = rideProvider.currentRide!;
  
  print('Status: ${ride.status}');
  print('Pickup: ${ride.pickupLocation.address}');
  print('Drop: ${ride.dropoffLocation.address}');
  print('OTP: ${ride.otp}');
}
```

#### Load Ride History

```dart
final rideProvider = Provider.of<RideProvider>(context, listen: false);

await rideProvider.loadRideHistory(page: 1);

// Access history
final rides = Provider.of<RideProvider>(context).rideHistory;
```

### WebSocket Integration

#### Connect to Socket

```dart
import 'package:pikkar_driver_app/core/services/socket_service.dart';

// Connect after login
await SocketService().connect();
```

#### Listen to Events

```dart
final socketService = SocketService();

// Connection status
socketService.onConnectionStatusChange.listen((isConnected) {
  print('Socket connected: $isConnected');
});

// New ride requests
socketService.onRideRequest.listen((ride) {
  print('New ride: ${ride.id}');
});

// Ride status updates
socketService.onRideStatusUpdate.listen((ride) {
  print('Ride updated: ${ride.status}');
});

// Location updates (if tracking another driver)
socketService.onLocationUpdate.listen((data) {
  print('Location: ${data['coordinates']}');
});
```

#### Emit Events

```dart
final socketService = SocketService();

// Update driver location
socketService.updateDriverLocation(
  longitude: 77.5946,
  latitude: 12.9716,
);

// Notify ride accepted
socketService.notifyRideAccepted(ride);

// Update ride status
socketService.updateRideStatus(ride);
```

#### Disconnect

```dart
// Disconnect on logout
SocketService().disconnect();
```

## API Endpoints Reference

### Authentication

- **POST** `/auth/register` - Register new user/driver
- **POST** `/auth/login` - Login with email and password
- **GET** `/auth/me` - Get current user profile
- **POST** `/auth/refresh-token` - Refresh access token
- **POST** `/auth/logout` - Logout

### Driver

- **POST** `/drivers/register` - Register as driver
- **GET** `/drivers/nearby` - Get nearby drivers
- **PUT** `/drivers/location` - Update driver location
- **PUT** `/drivers/toggle-online` - Toggle online/offline status

### Rides

- **POST** `/rides` - Request a ride
- **GET** `/rides` - Get all rides (paginated)
- **GET** `/rides/:id` - Get ride by ID
- **PUT** `/rides/:id/accept` - Accept ride (driver)
- **PUT** `/rides/:id/status` - Update ride status (driver)
- **PUT** `/rides/:id/cancel` - Cancel ride
- **PUT** `/rides/:id/rate` - Rate ride

## Error Handling

All API calls return an `ApiResponse<T>` object:

```dart
final response = await authService.login(
  email: email,
  password: password,
);

if (response.isSuccess) {
  // Success
  final user = response.data;
} else {
  // Error
  print('Error: ${response.message}');
}
```

Providers automatically handle errors and expose them via `errorMessage`:

```dart
final authProvider = Provider.of<AuthProvider>(context);

if (authProvider.errorMessage != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authProvider.errorMessage!)),
  );
  authProvider.clearError();
}
```

## Best Practices

### 1. Token Management

Tokens are automatically managed by `ApiClient`. The client:
- Adds tokens to all requests
- Automatically refreshes expired tokens
- Handles 401 errors

### 2. State Management

Use Provider for accessing state:

```dart
// Listen to changes (rebuilds widget)
final authProvider = Provider.of<AuthProvider>(context);

// Don't listen (for callbacks/functions)
final authProvider = Provider.of<AuthProvider>(context, listen: false);
```

### 3. Loading States

All providers expose an `isLoading` property:

```dart
if (authProvider.isLoading) {
  return const CircularProgressIndicator();
}
```

### 4. WebSocket Lifecycle

- Connect after successful login
- Disconnect on logout
- Reconnect on network recovery

### 5. Location Updates

Update driver location periodically when online:

```dart
Timer.periodic(const Duration(seconds: 10), (timer) async {
  if (driverProvider.isOnline) {
    final position = await Geolocator.getCurrentPosition();
    await driverProvider.updateLocation(
      longitude: position.longitude,
      latitude: position.latitude,
    );
  }
});
```

## Testing

### Using the API

1. Start your backend server
2. Update `ApiConstants.baseUrl` with your server URL
3. Test authentication endpoints first
4. Use the new `LoginScreenAPI` for email/password login
5. Check socket connection status

### Mock Data

For development without a backend, you can modify the services to return mock data:

```dart
Future<ApiResponse<UserModel>> login(...) async {
  // Return mock response
  return ApiResponse(
    status: 'success',
    data: UserModel(...),
  );
}
```

## Example Screens

See `lib/core/examples/api_integration_examples.dart` for complete examples of:
- Authentication flow
- Driver status management
- Ride request handling
- Ride history
- WebSocket integration

## Troubleshooting

### Connection Issues

- Verify `baseUrl` and `socketUrl` in `ApiConstants`
- Check network connectivity
- Verify server is running
- Check CORS settings on server

### Token Issues

- Tokens are stored securely in `FlutterSecureStorage`
- Clear app data to reset tokens
- Check token expiration times

### Socket Issues

- Verify socket URL
- Check authentication token
- Ensure socket server is running
- Check firewall/network restrictions

## Migration from Firebase

If migrating from Firebase Auth:

1. Replace Firebase login with API login
2. Use `LoginScreenAPI` instead of `LoginScreen`
3. Update authentication flow in splash screen
4. Remove Firebase dependencies if not needed

## Support

For issues or questions:
- Check the examples in `lib/core/examples/`
- Review API documentation
- Contact backend team for API-specific issues
