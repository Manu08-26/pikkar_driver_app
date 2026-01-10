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
    return VehicleType(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'ride',
      description: json['description'],
      icon: json['icon'],
      baseFare: json['baseFare']?.toDouble(),
      perKmRate: json['perKmRate']?.toDouble(),
      capacity: json['capacity'],
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
