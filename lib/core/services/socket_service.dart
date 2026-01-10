import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';
import '../models/ride_model.dart';
import 'token_storage_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Stream controllers for events
  final _rideRequestController = StreamController<RideModel>.broadcast();
  final _rideAcceptedController = StreamController<RideModel>.broadcast();
  final _rideStatusController = StreamController<RideModel>.broadcast();
  final _locationUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  // Getters for streams
  Stream<RideModel> get onRideRequest => _rideRequestController.stream;
  Stream<RideModel> get onRideAccepted => _rideAcceptedController.stream;
  Stream<RideModel> get onRideStatusUpdate => _rideStatusController.stream;
  Stream<Map<String, dynamic>> get onLocationUpdate => _locationUpdateController.stream;
  Stream<bool> get onConnectionStatusChange => _connectionStatusController.stream;

  bool get isConnected => _socket?.connected ?? false;

  // Connect to socket server
  Future<void> connect() async {
    if (_socket?.connected == true) {
      print('Socket already connected');
      return;
    }

    try {
      final token = await _tokenStorage.getAccessToken();
      
      _socket = IO.io(
        ApiConstants.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .setAuth({
              'token': token,
            })
            .build(),
      );

      _setupEventListeners();
      
      print('Socket connecting...');
    } catch (e) {
      print('Socket connection error: $e');
      _connectionStatusController.add(false);
    }
  }

  // Setup event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      print('✅ Socket connected');
      _connectionStatusController.add(true);
      
      // Join driver room
      joinRoom('driver');
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
      _connectionStatusController.add(false);
    });

    _socket!.onConnectError((error) {
      print('Socket connection error: $error');
      _connectionStatusController.add(false);
    });

    _socket!.onError((error) {
      print('Socket error: $error');
    });

    _socket!.onReconnect((attempt) {
      print('Socket reconnected (attempt $attempt)');
      _connectionStatusController.add(true);
    });

    // Custom events
    
    // New ride request (for drivers)
    _socket!.on(ApiConstants.socketRideNew, (data) {
      print('🚗 New ride request: $data');
      try {
        final ride = RideModel.fromJson(data);
        _rideRequestController.add(ride);
      } catch (e) {
        print('Error parsing ride request: $e');
      }
    });

    // Ride accepted (for users)
    _socket!.on(ApiConstants.socketRideAccepted, (data) {
      print('✅ Ride accepted: $data');
      try {
        final ride = RideModel.fromJson(data);
        _rideAcceptedController.add(ride);
      } catch (e) {
        print('Error parsing ride accepted: $e');
      }
    });

    // Ride status update
    _socket!.on(ApiConstants.socketRideStatusUpdate, (data) {
      print('📍 Ride status update: $data');
      try {
        final ride = RideModel.fromJson(data);
        _rideStatusController.add(ride);
      } catch (e) {
        print('Error parsing ride status: $e');
      }
    });

    // Driver location update
    _socket!.on(ApiConstants.socketDriverLocationUpdate, (data) {
      print('📍 Driver location update: $data');
      _locationUpdateController.add(data as Map<String, dynamic>);
    });
  }

  // Join a room
  void joinRoom(String room) {
    if (_socket?.connected == true) {
      _socket!.emit(ApiConstants.socketJoin, room);
      print('Joined room: $room');
    }
  }

  // Emit driver location
  void updateDriverLocation({
    required double longitude,
    required double latitude,
  }) {
    if (_socket?.connected == true) {
      _socket!.emit(ApiConstants.socketDriverLocation, {
        'longitude': longitude,
        'latitude': latitude,
      });
      print('Driver location updated: [$longitude, $latitude]');
    }
  }

  // Emit ride request (for broadcasting)
  void broadcastRideRequest(RideModel ride) {
    if (_socket?.connected == true) {
      _socket!.emit(ApiConstants.socketRideRequest, ride.toJson());
      print('Ride request broadcasted');
    }
  }

  // Emit ride accepted
  void notifyRideAccepted(RideModel ride) {
    if (_socket?.connected == true) {
      _socket!.emit(ApiConstants.socketRideAccepted, ride.toJson());
      print('Ride accepted notification sent');
    }
  }

  // Emit ride status update
  void updateRideStatus(RideModel ride) {
    if (_socket?.connected == true) {
      _socket!.emit(ApiConstants.socketRideStatus, ride.toJson());
      print('Ride status updated');
    }
  }

  // Disconnect socket
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      print('Socket disconnected');
    }
  }

  // Dispose (cleanup)
  void dispose() {
    disconnect();
    _rideRequestController.close();
    _rideAcceptedController.close();
    _rideStatusController.close();
    _locationUpdateController.close();
    _connectionStatusController.close();
  }

  // Reconnect
  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect();
  }
}
