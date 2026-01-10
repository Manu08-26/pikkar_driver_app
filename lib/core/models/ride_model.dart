import 'user_model.dart';
import 'driver_model.dart';

class RideModel {
  final String id;
  final String userId;
  final UserModel? user;
  final String? driverId;
  final DriverModel? driver;
  final RideLocation pickupLocation;
  final RideLocation dropoffLocation;
  final String vehicleType;
  final String status;
  final double? estimatedFare;
  final double? actualFare;
  final double distance;
  final String? otp;
  final String paymentMethod;
  final String? paymentStatus;
  final DateTime? scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? rating;
  final String? review;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  RideModel({
    required this.id,
    required this.userId,
    this.user,
    this.driverId,
    this.driver,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.vehicleType,
    required this.status,
    this.estimatedFare,
    this.actualFare,
    required this.distance,
    this.otp,
    required this.paymentMethod,
    this.paymentStatus,
    this.scheduledTime,
    this.startTime,
    this.endTime,
    this.rating,
    this.review,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] is String ? json['userId'] : json['userId']?['_id'] ?? '',
      user: json['userId'] is Map<String, dynamic> 
          ? UserModel.fromJson(json['userId'])
          : null,
      driverId: json['driverId'] is String 
          ? json['driverId'] 
          : json['driverId']?['_id'],
      driver: json['driverId'] is Map<String, dynamic>
          ? DriverModel.fromJson(json['driverId'])
          : null,
      pickupLocation: RideLocation.fromJson(json['pickupLocation']),
      dropoffLocation: RideLocation.fromJson(json['dropoffLocation']),
      vehicleType: json['vehicleType'] ?? '',
      status: json['status'] ?? 'requested',
      estimatedFare: json['estimatedFare']?.toDouble(),
      actualFare: json['actualFare']?.toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      otp: json['otp'],
      paymentMethod: json['paymentMethod'] ?? 'cash',
      paymentStatus: json['paymentStatus'],
      scheduledTime: json['scheduledTime'] != null 
          ? DateTime.parse(json['scheduledTime'])
          : null,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : null,
      rating: json['rating']?.toDouble(),
      review: json['review'],
      cancellationReason: json['cancellationReason'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'driverId': driverId,
      'pickupLocation': pickupLocation.toJson(),
      'dropoffLocation': dropoffLocation.toJson(),
      'vehicleType': vehicleType,
      'status': status,
      'estimatedFare': estimatedFare,
      'actualFare': actualFare,
      'distance': distance,
      'otp': otp,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'rating': rating,
      'review': review,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RideModel copyWith({
    String? id,
    String? userId,
    UserModel? user,
    String? driverId,
    DriverModel? driver,
    RideLocation? pickupLocation,
    RideLocation? dropoffLocation,
    String? vehicleType,
    String? status,
    double? estimatedFare,
    double? actualFare,
    double? distance,
    String? otp,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? scheduledTime,
    DateTime? startTime,
    DateTime? endTime,
    double? rating,
    String? review,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RideModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      driverId: driverId ?? this.driverId,
      driver: driver ?? this.driver,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      actualFare: actualFare ?? this.actualFare,
      distance: distance ?? this.distance,
      otp: otp ?? this.otp,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RideLocation {
  final List<double> coordinates; // [longitude, latitude]
  final String address;

  RideLocation({
    required this.coordinates,
    required this.address,
  });

  factory RideLocation.fromJson(Map<String, dynamic> json) {
    return RideLocation(
      coordinates: List<double>.from(
        (json['coordinates'] as List).map((e) => e.toDouble()),
      ),
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates,
      'address': address,
    };
  }

  double get longitude => coordinates[0];
  double get latitude => coordinates[1];
}

// Ride statuses
class RideStatus {
  static const String requested = 'requested';
  static const String accepted = 'accepted';
  static const String arrived = 'arrived';
  static const String started = 'started';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
}
