import 'user_model.dart';

class DriverModel {
  final String id;
  final String userId;
  final UserModel? user;
  final String licenseNumber;
  final String? licenseExpiry;
  final String vehicleType;
  final String vehicleModel;
  final String vehicleMake;
  final int? vehicleYear;
  final String? vehicleColor;
  final String vehicleNumber;
  final LocationCoordinates? currentLocation;
  final bool isOnline;
  final bool isAvailable;
  final double rating;
  final String verificationStatus;
  final int totalRides;
  final double totalEarnings;

  DriverModel({
    required this.id,
    required this.userId,
    this.user,
    required this.licenseNumber,
    this.licenseExpiry,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehicleMake,
    this.vehicleYear,
    this.vehicleColor,
    required this.vehicleNumber,
    this.currentLocation,
    this.isOnline = false,
    this.isAvailable = false,
    this.rating = 0.0,
    this.verificationStatus = 'pending',
    this.totalRides = 0,
    this.totalEarnings = 0.0,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] is String ? json['userId'] : json['userId']?['_id'] ?? '',
      user: json['userId'] is Map<String, dynamic> 
          ? UserModel.fromJson(json['userId'])
          : null,
      licenseNumber: json['licenseNumber'] ?? '',
      licenseExpiry: json['licenseExpiry'],
      vehicleType: json['vehicleType'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleMake: json['vehicleMake'] ?? '',
      vehicleYear: json['vehicleYear'],
      vehicleColor: json['vehicleColor'],
      vehicleNumber: json['vehicleNumber'] ?? '',
      currentLocation: json['currentLocation'] != null
          ? LocationCoordinates.fromJson(json['currentLocation'])
          : null,
      isOnline: json['isOnline'] ?? false,
      isAvailable: json['isAvailable'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      // Backend uses `status` (pending/approved/rejected). Keep `verificationStatus`
      // for UI compatibility, but map from `status` first.
      verificationStatus: json['status'] ?? json['verificationStatus'] ?? 'pending',
      totalRides: json['totalRides'] ?? 0,
      totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'licenseNumber': licenseNumber,
      'licenseExpiry': licenseExpiry,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'vehicleMake': vehicleMake,
      'vehicleYear': vehicleYear,
      'vehicleColor': vehicleColor,
      'vehicleNumber': vehicleNumber,
      'currentLocation': currentLocation?.toJson(),
      'isOnline': isOnline,
      'isAvailable': isAvailable,
      'rating': rating,
      'verificationStatus': verificationStatus,
      'totalRides': totalRides,
      'totalEarnings': totalEarnings,
    };
  }

  DriverModel copyWith({
    String? id,
    String? userId,
    UserModel? user,
    String? licenseNumber,
    String? licenseExpiry,
    String? vehicleType,
    String? vehicleModel,
    String? vehicleMake,
    int? vehicleYear,
    String? vehicleColor,
    String? vehicleNumber,
    LocationCoordinates? currentLocation,
    bool? isOnline,
    bool? isAvailable,
    double? rating,
    String? verificationStatus,
    int? totalRides,
    double? totalEarnings,
  }) {
    return DriverModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      currentLocation: currentLocation ?? this.currentLocation,
      isOnline: isOnline ?? this.isOnline,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      totalRides: totalRides ?? this.totalRides,
      totalEarnings: totalEarnings ?? this.totalEarnings,
    );
  }
}

class LocationCoordinates {
  final String type;
  final List<double> coordinates; // [longitude, latitude]

  LocationCoordinates({
    this.type = 'Point',
    required this.coordinates,
  });

  factory LocationCoordinates.fromJson(Map<String, dynamic> json) {
    return LocationCoordinates(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(
        (json['coordinates'] as List).map((e) => e.toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  double get longitude => coordinates[0];
  double get latitude => coordinates[1];
}
