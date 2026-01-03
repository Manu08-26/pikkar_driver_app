import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../ride/ride_request_screen.dart';
import '../menu/menu_drawer.dart';
import '../menu/earnings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppTheme _appTheme = AppTheme();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _mapController;
  bool _isOnDuty = false;
  double _todayEarnings = 530.0;
  LatLng? _currentLocation;

  // Default location (Hyderabad)
  static const LatLng _defaultLocation = LatLng(17.385044, 78.486671);

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _mapController?.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      if (_mapController != null && _currentLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    }
  }

  void _toggleDutyStatus() {
    setState(() {
      _isOnDuty = !_isOnDuty;
    });

    if (_isOnDuty) {
      // Simulate receiving a ride request after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isOnDuty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RideRequestScreen(
                pickupAddress: 'Hotel Grand Sitara',
                pickupDetails: 'Abids Chiragali Line, Nampalley, Hyderabad, Telangana 500053',
                dropAddress: 'Lulu Mall',
                dropDetails: 'Banjara Hills Road No. 12, Hyderabad, Telangana 500002',
                distance: 8.4,
                fare: 70.0,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: MenuDrawer(scaffoldKey: _scaffoldKey),
        body: SafeArea(
          child: Stack(
            children: [
              // Map
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation ?? _defaultLocation,
                  zoom: 14.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
              ),

              // Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Header with menu, duty toggle, notifications
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.padding(context, 16),
                          vertical: Responsive.padding(context, 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Menu Icon
                            IconButton(
                              icon: Icon(
                                Icons.menu,
                                size: Responsive.iconSize(context, 28),
                                color: _appTheme.textColor,
                              ),
                              onPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
                              },
                            ),
                            // Duty Toggle
                            GestureDetector(
                              onTap: _toggleDutyStatus,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.padding(context, 16),
                                  vertical: Responsive.padding(context, 10),
                                ),
                                decoration: BoxDecoration(
                                  color: _isOnDuty
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: _isOnDuty
                                        ? Colors.green.shade700
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _isOnDuty ? 'On Duty' : 'Off Duty',
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(context, 16),
                                        fontWeight: FontWeight.w600,
                                        color: _isOnDuty
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(width: Responsive.spacing(context, 8)),
                                    Container(
                                      width: Responsive.wp(context, 8),
                                      height: Responsive.wp(context, 8),
                                      decoration: BoxDecoration(
                                        color: _isOnDuty
                                            ? Colors.white
                                            : Colors.grey.shade500,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Notification Icon
                            IconButton(
                              icon: Icon(
                                Icons.notifications_outlined,
                                size: Responsive.iconSize(context, 28),
                                color: _appTheme.textColor,
                              ),
                              onPressed: () {
                                // Open notifications
                              },
                            ),
                          ],
                        ),
                      ),
                      // Today's Earnings
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EarningsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.padding(context, 16),
                            vertical: Responsive.padding(context, 12),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Today Earning\'s',
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, 18),
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: Responsive.spacing(context, 8)),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: Responsive.iconSize(context, 16),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${_todayEarnings.toStringAsFixed(0)}/-',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 20),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Offline Message
              if (!_isOnDuty)
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.padding(context, 32),
                      vertical: Responsive.padding(context, 24),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: Responsive.padding(context, 32),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'You are currently offline. Go green to start.',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 16),
                        fontWeight: FontWeight.w500,
                        color: _appTheme.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

