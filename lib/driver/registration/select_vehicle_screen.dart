import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/models/vehicle_type_model.dart';
import '../../core/services/vehicle_service.dart';
import 'onboard_vehicle_screen.dart';

class SelectVehicleScreen extends StatefulWidget {
  const SelectVehicleScreen({super.key});

  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
  final AppTheme _appTheme = AppTheme();
  final VehicleService _vehicleService = VehicleService();
  
  String? _selectedVehicleId;
  VehicleType? _selectedVehicle;
  
  bool _isLoading = true;
  String? _errorMessage;
  
  List<VehicleType> _rideVehicles = [];
  List<VehicleType> _deliveryVehicles = [];

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    _loadVehicleTypes();
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _loadVehicleTypes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load both ride and delivery vehicles in parallel
      final results = await Future.wait([
        _vehicleService.getRideVehicles(),
        _vehicleService.getDeliveryVehicles(),
      ]);

      if (mounted) {
        setState(() {
          if (results[0].isSuccess && results[0].data != null) {
            _rideVehicles = results[0].data!;
          }
          if (results[1].isSuccess && results[1].data != null) {
            _deliveryVehicles = results[1].data!;
          }
          
          // If API fails, use fallback data
          if (_rideVehicles.isEmpty && _deliveryVehicles.isEmpty) {
            _loadFallbackData();
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load vehicle types';
          _isLoading = false;
          _loadFallbackData();
        });
      }
    }
  }

  void _loadFallbackData() {
    // Fallback data if API is not available
    _rideVehicles = [
      VehicleType(
        id: 'bike',
        name: 'Bike',
        category: 'ride',
        description: 'Two-wheeler for quick rides',
        baseFare: 30,
        perKmRate: 8,
        capacity: 1,
      ),
      VehicleType(
        id: 'auto',
        name: 'Auto',
        category: 'ride',
        description: 'Three-wheeler auto-rickshaw',
        baseFare: 40,
        perKmRate: 10,
        capacity: 3,
      ),
      VehicleType(
        id: 'car',
        name: 'Cab',
        category: 'ride',
        description: 'Comfortable sedan car',
        baseFare: 60,
        perKmRate: 15,
        capacity: 4,
      ),
    ];

    _deliveryVehicles = [
      VehicleType(
        id: 'parcel',
        name: 'Parcel',
        category: 'delivery',
        description: 'Small parcels & documents',
        baseFare: 50,
        perKmRate: 12,
        capacity: 2,
      ),
      VehicleType(
        id: 'truck',
        name: 'Truck',
        category: 'delivery',
        description: 'Large cargo transport',
        baseFare: 200,
        perKmRate: 25,
        capacity: 10,
      ),
      VehicleType(
        id: 'tempo',
        name: 'Tempo',
        category: 'delivery',
        description: 'Medium-sized goods vehicle',
        baseFare: 150,
        perKmRate: 20,
        capacity: 6,
      ),
    ];
  }

  void _handleVehicleSelection(VehicleType vehicle) {
    setState(() {
      _selectedVehicleId = vehicle.id;
      _selectedVehicle = vehicle;
    });

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 400), () {
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
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: _appTheme.brandRed,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Select Your Vehicle',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : _buildSingleScrollView(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_appTheme.brandRed),
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          Text(
            'Loading vehicle types...',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
              color: _appTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.padding(context, 24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: Responsive.iconSize(context, 64),
              color: _appTheme.brandRed,
            ),
            SizedBox(height: Responsive.spacing(context, 16)),
            Text(
              _errorMessage ?? 'Failed to load vehicles',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                color: _appTheme.textColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.spacing(context, 24)),
            ElevatedButton(
              onPressed: _loadVehicleTypes,
              style: ElevatedButton.styleFrom(
                backgroundColor: _appTheme.brandRed,
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 32),
                  vertical: Responsive.padding(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 16),
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleScrollView() {
    return RefreshIndicator(
      onRefresh: _loadVehicleTypes,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 12)),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: Responsive.iconSize(context, 20),
                  ),
                  SizedBox(width: Responsive.spacing(context, 8)),
                  Expanded(
                    child: Text(
                      'Select the vehicle type you want to register',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 13),
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 24)),
            
            // Ride Vehicles Section
            if (_rideVehicles.isNotEmpty) ...[
              _buildSectionHeader('Ride Vehicles', Icons.directions_car),
              SizedBox(height: Responsive.spacing(context, 16)),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: Responsive.spacing(context, 12),
                  mainAxisSpacing: Responsive.spacing(context, 12),
                  childAspectRatio: 0.85,
                ),
                itemCount: _rideVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _rideVehicles[index];
                  final isSelected = _selectedVehicleId == vehicle.id;
                  return _buildModernVehicleCard(vehicle, isSelected);
                },
              ),
              SizedBox(height: Responsive.spacing(context, 32)),
            ],
            
            // Delivery Vehicles Section
            if (_deliveryVehicles.isNotEmpty) ...[
              _buildSectionHeader('Delivery Vehicles', Icons.local_shipping),
              SizedBox(height: Responsive.spacing(context, 16)),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: Responsive.spacing(context, 12),
                  mainAxisSpacing: Responsive.spacing(context, 12),
                  childAspectRatio: 0.85,
                ),
                itemCount: _deliveryVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _deliveryVehicles[index];
                  final isSelected = _selectedVehicleId == vehicle.id;
                  return _buildModernVehicleCard(vehicle, isSelected);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.padding(context, 8)),
          decoration: BoxDecoration(
            color: _appTheme.brandRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: _appTheme.brandRed,
            size: Responsive.iconSize(context, 20),
          ),
        ),
        SizedBox(width: Responsive.spacing(context, 12)),
        Text(
          title,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: _appTheme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildModernVehicleCard(VehicleType vehicle, bool isSelected) {
    return GestureDetector(
      onTap: () => _handleVehicleSelection(vehicle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _appTheme.brandRed : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _appTheme.brandRed.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Selection indicator
            if (isSelected)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: EdgeInsets.all(Responsive.padding(context, 8)),
                  padding: EdgeInsets.all(Responsive.padding(context, 4)),
                  decoration: BoxDecoration(
                    color: _appTheme.brandRed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: Responsive.iconSize(context, 16),
                  ),
                ),
              )
            else
              SizedBox(height: Responsive.spacing(context, 28)),

            // Vehicle image
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 16),
                ),
                child: Image.asset(
                  vehicle.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      vehicle.category == 'ride'
                          ? Icons.directions_car
                          : Icons.local_shipping,
                      size: Responsive.iconSize(context, 56),
                      color: _appTheme.textGrey,
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: Responsive.spacing(context, 8)),

            // Vehicle name
            Text(
              vehicle.name,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: isSelected ? _appTheme.brandRed : _appTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),

            // Vehicle description
            if (vehicle.description != null)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 8),
                  vertical: Responsive.padding(context, 4),
                ),
                child: Text(
                  vehicle.description!,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 11),
                    color: _appTheme.textGrey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Pricing info
            if (vehicle.baseFare != null)
              Container(
                margin: EdgeInsets.only(
                  top: Responsive.padding(context, 8),
                  bottom: Responsive.padding(context, 12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 12),
                  vertical: Responsive.padding(context, 6),
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _appTheme.brandRed.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.currency_rupee,
                      size: Responsive.iconSize(context, 12),
                      color: isSelected ? _appTheme.brandRed : _appTheme.textGrey,
                    ),
                    Text(
                      '${vehicle.baseFare?.toInt()} base',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 11),
                        fontWeight: FontWeight.w600,
                        color: isSelected ? _appTheme.brandRed : _appTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
