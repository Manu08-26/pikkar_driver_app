class ParcelModel {
  final String id;
  final String trackingNumber;
  final String status;
  final double fare;
  final double? weightKg;
  final String pickupAddress;
  final String dropoffAddress;

  ParcelModel({
    required this.id,
    required this.trackingNumber,
    required this.status,
    required this.fare,
    this.weightKg,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  factory ParcelModel.fromJson(Map<String, dynamic> json) {
    final details = json['parcelDetails'] as Map<String, dynamic>?;
    final pickup = json['pickupLocation'] as Map<String, dynamic>?;
    final drop = json['dropoffLocation'] as Map<String, dynamic>?;
    return ParcelModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      trackingNumber: (json['trackingNumber'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      fare: (json['fare'] ?? 0).toDouble(),
      weightKg: details?['weight'] != null ? (details!['weight'] as num).toDouble() : null,
      pickupAddress: (pickup?['address'] ?? '').toString(),
      dropoffAddress: (drop?['address'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackingNumber': trackingNumber,
      'status': status,
      'fare': fare,
      'weightKg': weightKg,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
    };
  }
}

