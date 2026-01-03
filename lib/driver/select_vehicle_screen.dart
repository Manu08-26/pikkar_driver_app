import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';
import 'onboard_vehicle_screen.dart';

class SelectVehicleScreen extends StatefulWidget {
  const SelectVehicleScreen({super.key});

  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
  final AppTheme _appTheme = AppTheme();
  String? _selectedVehicle;

  final List<Map<String, dynamic>> _rideVehicles = [
    {
      'id': 'bike',
      'name': 'Bike',
      'asset': 'assets/Bike.png',
    },
    {
      'id': 'auto',
      'name': 'Auto',
      'asset': 'assets/Auto.png',
    
    },
    {
      'id': 'car',
      'name': 'Cab',
      'asset': 'assets/Cab.png',
    },
  ];

  final List<Map<String, dynamic>> _deliveryVehicles = [
    {
      'id': 'parcel',
      'name': 'Parcel',
      'asset': 'assets/Truck _Mini.png',
    },
    {
      'id': 'truck',
      'name': 'Truck',
      'asset': 'assets/Truck_Large.png',
    },
    {
      'id': 'tempo',
      'name': 'Tempo',
      'asset': 'assets/Tempo.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _handleVehicleSelection(String vehicleId) {
    setState(() {
      _selectedVehicle = vehicleId;
    });

    // Navigate to onboard vehicle screen after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const OnboardVehicleScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Select Your Vehicle',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: _appTheme.textColor,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, 24),
              vertical: Responsive.padding(context, 24),
            ),
            child: Column(
              children: [
                // Ride Section
                Text(
                  'Ride',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 20),
                    fontWeight: FontWeight.w600,
                    color: _appTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.spacing(context, 20)),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: Responsive.spacing(context, 16),
                    mainAxisSpacing: Responsive.spacing(context, 16),
                    childAspectRatio: 1,
                  ),
                  itemCount: _rideVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _rideVehicles[index];
                    final isSelected = _selectedVehicle == vehicle['id'];

                    return _buildVehicleCard(vehicle, isSelected);
                  },
                ),
                SizedBox(height: Responsive.spacing(context, 32)),
                // Delivery Section
                Text(
                  'Delivery',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 20),
                    fontWeight: FontWeight.w600,
                    color: _appTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.spacing(context, 20)),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: Responsive.spacing(context, 16),
                    mainAxisSpacing: Responsive.spacing(context, 16),
                    childAspectRatio: 1,
                  ),
                  itemCount: _deliveryVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _deliveryVehicles[index];
                    final isSelected = _selectedVehicle == vehicle['id'];

                    return _buildVehicleCard(vehicle, isSelected);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, bool isSelected) {
    return GestureDetector(
      onTap: () => _handleVehicleSelection(vehicle['id']),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _appTheme.brandRed
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _appTheme.brandRed.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(Responsive.padding(context, 16)),
            child: Image.asset(
              vehicle['asset'],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image not found
                return Icon(
                  Icons.directions_car,
                  size: Responsive.iconSize(context, 48),
                  color: _appTheme.textGrey,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

