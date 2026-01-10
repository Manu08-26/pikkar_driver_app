import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/driver_provider.dart';
import '../../core/providers/ride_provider.dart';
import '../../core/services/socket_service.dart';
import '../../core/models/ride_model.dart';

/// Example: How to use the API services in your screens
/// 
/// This file demonstrates how to integrate the Pikkar API services
/// into your Flutter screens using Provider for state management.

// ============================================================================
// 1. AUTHENTICATION EXAMPLE
// ============================================================================

class AuthenticationExample extends StatelessWidget {
  const AuthenticationExample({super.key});

  Future<void> _loginExample(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Login with email and password
    final success = await authProvider.login(
      email: 'driver@example.com',
      password: 'password123',
    );

    if (success) {
      // Login successful - connect socket
      await SocketService().connect();
      
      // Navigate to home screen
      // Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // Show error
      print('Login failed: ${authProvider.errorMessage}');
    }
  }

  Future<void> _logoutExample(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Disconnect socket first
    SocketService().disconnect();
    
    // Logout
    await authProvider.logout();
    
    // Navigate to login screen
    // Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    // Access auth state
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoading) {
      return const CircularProgressIndicator();
    }

    if (authProvider.isAuthenticated) {
      return Text('Welcome, ${authProvider.user?.fullName}');
    }

    return const Text('Please login');
  }
}

// ============================================================================
// 2. DRIVER STATUS EXAMPLE
// ============================================================================

class DriverStatusExample extends StatefulWidget {
  const DriverStatusExample({super.key});

  @override
  State<DriverStatusExample> createState() => _DriverStatusExampleState();
}

class _DriverStatusExampleState extends State<DriverStatusExample> {
  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  // Update driver location every 10 seconds
  void _startLocationUpdates() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    
    while (mounted) {
      try {
        final position = await Geolocator.getCurrentPosition();
        
        // Update location via API
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
      } catch (e) {
        print('Error updating location: $e');
      }

      await Future.delayed(const Duration(seconds: 10));
    }
  }

  Future<void> _toggleOnlineStatus() async {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    
    final success = await driverProvider.toggleOnlineStatus();
    
    if (success) {
      print('Status toggled: ${driverProvider.isOnline}');
    } else {
      print('Failed to toggle status: ${driverProvider.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);
    
    return Switch(
      value: driverProvider.isOnline,
      onChanged: (_) => _toggleOnlineStatus(),
    );
  }
}

// ============================================================================
// 3. RIDE MANAGEMENT EXAMPLE
// ============================================================================

class RideManagementExample extends StatefulWidget {
  const RideManagementExample({super.key});

  @override
  State<RideManagementExample> createState() => _RideManagementExampleState();
}

class _RideManagementExampleState extends State<RideManagementExample> {
  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  // Listen for incoming ride requests via WebSocket
  void _setupSocketListeners() {
    final socketService = SocketService();
    
    // Listen for new ride requests
    socketService.onRideRequest.listen((ride) {
      if (mounted) {
        _showRideRequestDialog(ride);
      }
    });

    // Listen for ride status updates
    socketService.onRideStatusUpdate.listen((ride) {
      print('Ride status updated: ${ride.status}');
    });
  }

  void _showRideRequestDialog(RideModel ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Ride Request'),
        content: Text('Pickup: ${ride.pickupLocation.address}\n'
            'Drop: ${ride.dropoffLocation.address}\n'
            'Fare: ₹${ride.estimatedFare}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectRide(ride.id);
            },
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

  Future<void> _acceptRide(String rideId) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    
    final success = await rideProvider.acceptRide(rideId);
    
    if (success) {
      print('Ride accepted!');
      // Navigate to ride detail screen
      // Navigator.pushNamed(context, AppRoutes.rideDetail);
    } else {
      print('Failed to accept ride: ${rideProvider.errorMessage}');
    }
  }

  Future<void> _rejectRide(String rideId) async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    rideProvider.removePendingRide(rideId);
  }

  Future<void> _markArrived() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    
    final success = await rideProvider.markArrived();
    
    if (success) {
      print('Marked as arrived');
    }
  }

  Future<void> _startRide() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    
    final success = await rideProvider.startRide();
    
    if (success) {
      print('Ride started');
    }
  }

  Future<void> _completeRide() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    
    final success = await rideProvider.completeRide();
    
    if (success) {
      print('Ride completed');
      // Navigate to rate customer screen
    }
  }

  Future<void> _cancelRide() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    
    final success = await rideProvider.cancelRide('Customer requested cancellation');
    
    if (success) {
      print('Ride cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    
    if (rideProvider.currentRide == null) {
      return const Text('No active ride');
    }

    final ride = rideProvider.currentRide!;
    
    return Column(
      children: [
        Text('Status: ${ride.status}'),
        Text('Pickup: ${ride.pickupLocation.address}'),
        Text('Drop: ${ride.dropoffLocation.address}'),
        
        if (ride.status == RideStatus.accepted)
          ElevatedButton(
            onPressed: _markArrived,
            child: const Text('Mark Arrived'),
          ),
        
        if (ride.status == RideStatus.arrived)
          ElevatedButton(
            onPressed: _startRide,
            child: const Text('Start Ride'),
          ),
        
        if (ride.status == RideStatus.started)
          ElevatedButton(
            onPressed: _completeRide,
            child: const Text('Complete Ride'),
          ),
        
        TextButton(
          onPressed: _cancelRide,
          child: const Text('Cancel Ride'),
        ),
      ],
    );
  }
}

// ============================================================================
// 4. RIDE HISTORY EXAMPLE
// ============================================================================

class RideHistoryExample extends StatefulWidget {
  const RideHistoryExample({super.key});

  @override
  State<RideHistoryExample> createState() => _RideHistoryExampleState();
}

class _RideHistoryExampleState extends State<RideHistoryExample> {
  @override
  void initState() {
    super.initState();
    _loadRideHistory();
  }

  Future<void> _loadRideHistory() async {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    await rideProvider.loadRideHistory();
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    
    if (rideProvider.isLoading) {
      return const CircularProgressIndicator();
    }

    final rides = rideProvider.rideHistory;
    
    if (rides.isEmpty) {
      return const Text('No ride history');
    }

    return ListView.builder(
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];
        return ListTile(
          title: Text(ride.dropoffLocation.address),
          subtitle: Text('₹${ride.actualFare ?? ride.estimatedFare}'),
          trailing: Text(ride.status),
        );
      },
    );
  }
}

// ============================================================================
// 5. DRIVER REGISTRATION EXAMPLE
// ============================================================================

class DriverRegistrationExample extends StatelessWidget {
  const DriverRegistrationExample({super.key});

  Future<void> _registerDriver(BuildContext context) async {
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

    if (success) {
      print('Driver registered successfully');
      // Navigate to verification pending screen
    } else {
      print('Registration failed: ${driverProvider.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _registerDriver(context),
      child: const Text('Register as Driver'),
    );
  }
}

// ============================================================================
// 6. SOCKET CONNECTION EXAMPLE
// ============================================================================

class SocketConnectionExample extends StatefulWidget {
  const SocketConnectionExample({super.key});

  @override
  State<SocketConnectionExample> createState() => _SocketConnectionExampleState();
}

class _SocketConnectionExampleState extends State<SocketConnectionExample> {
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _listenToConnectionStatus();
  }

  void _listenToConnectionStatus() {
    SocketService().onConnectionStatusChange.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 12,
          color: _isConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(_isConnected ? 'Connected' : 'Disconnected'),
      ],
    );
  }
}
