// Vehicle Type Model
class VehicleType {
  final String id;
  final String name;
  final String category; // 'ride' or 'delivery'
  final String? description;
  final String? icon;
  final double? baseFare;
  final double? perKmRate;
  final int? capacity;
  final bool isActive;

  VehicleType({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.icon,
    this.baseFare,
    this.perKmRate,
    this.capacity,
    this.isActive = true,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] as Map<String, dynamic>?;
    final cap = json['capacity'];

    // Backend categories are 'ride' | 'parcel' | 'freight'.
    // Driver UI uses 'ride' | 'delivery' terminology.
    final rawCategory = (json['category'] ?? 'ride').toString();
    final resolvedCategory = rawCategory == 'parcel' ? 'delivery' : rawCategory;

    // Normalize pricing fields between ride and parcel vehicles.
    final base = (pricing?['baseFare'] ?? pricing?['basePrice'] ?? json['baseFare']) as num?;
    final perKm = (pricing?['perKmRate'] ?? pricing?['pricePerKm'] ?? json['perKmRate']) as num?;

    int? resolvedCapacity;
    if (cap is int) {
      resolvedCapacity = cap;
    } else if (cap is num) {
      resolvedCapacity = cap.toInt();
    } else if (cap is Map<String, dynamic>) {
      final passengers = cap['passengers'];
      final maxWeight = cap['maxWeight'];
      if (passengers is num) resolvedCapacity = passengers.toInt();
      if (resolvedCapacity == null && maxWeight is num) resolvedCapacity = maxWeight.toInt();
    }

    return VehicleType(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      category: resolvedCategory,
      description: json['description'],
      icon: json['icon'],
      baseFare: base?.toDouble(),
      perKmRate: perKm?.toDouble(),
      capacity: resolvedCapacity,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'icon': icon,
      'baseFare': baseFare,
      'perKmRate': perKmRate,
      'capacity': capacity,
      'isActive': isActive,
    };
  }

  // Local asset mapping for fallback
  String get assetPath {
    switch (name.toLowerCase()) {
      case 'bike':
      case 'motorcycle':
        return 'assets/Bike.png';
      case 'auto':
      case 'auto-rickshaw':
        return 'assets/Auto.png';
      case 'car':
      case 'cab':
      case 'sedan':
        return 'assets/Cab.png';
      case 'parcel':
      case 'mini truck':
        return 'assets/Truck _Mini.png';
      case 'truck':
      case 'large truck':
        return 'assets/Truck_Large.png';
      case 'tempo':
        return 'assets/Tempo.png';
      default:
        return '';
    }
  }
}
