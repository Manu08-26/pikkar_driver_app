import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'ride_otp_screen.dart';

class RideNavigationScreen extends StatefulWidget {
  final String pickupAddress;
  final String pickupDetails;
  final String dropAddress;
  final String dropDetails;
  final double distance;
  final double fare;

  const RideNavigationScreen({
    super.key,
    required this.pickupAddress,
    required this.pickupDetails,
    required this.dropAddress,
    required this.dropDetails,
    required this.distance,
    required this.fare,
  });

  @override
  State<RideNavigationScreen> createState() => _RideNavigationScreenState();
}

class _RideNavigationScreenState extends State<RideNavigationScreen> {
  final AppTheme _appTheme = AppTheme();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String _rideStatus = 'arriving'; // 'arriving', 'arrived'
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;

  static const LatLng _pickupLocation = LatLng(17.385044, 78.486671);

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    _getCurrentLocation();
    _setupMarkers();
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
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _currentLocation = _pickupLocation; // Fallback to pickup location
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _currentLocation = _pickupLocation;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _currentLocation = _pickupLocation;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      // Move camera to current location
      if (_mapController != null && _currentLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation!, 15.0),
        );
      }

      // Start listening to location updates
      _listenToLocationUpdates();
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoadingLocation = false;
        _currentLocation = _pickupLocation;
      });
    }
  }

  void _listenToLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }

  void _setupMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: _pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.pickupAddress),
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _handleArrivedAtPickup() {
    setState(() {
      _rideStatus = 'arrived';
    });
  }

  void _handleStartRide() {
    // Navigate to OTP screen before starting ride
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RideOTPScreen(
          pickupAddress: widget.pickupAddress,
          dropAddress: widget.dropAddress,
          dropDetails: widget.dropDetails,
          distance: widget.distance,
          fare: widget.fare,
        ),
      ),
    );
  }

  void _handleCallCustomer() {
    // Make phone call
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Map
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation ?? _pickupLocation,
                  zoom: 15.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                trafficEnabled: false,
              ),

              // Back Button
              Positioned(
                top: Responsive.padding(context, 16),
                left: Responsive.padding(context, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: _appTheme.textColor,
                      size: Responsive.iconSize(context, 24),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // Bottom Sheet
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(Responsive.padding(context, 20)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.padding(context, 16),
                          vertical: Responsive.padding(context, 12),
                        ),
                        decoration: BoxDecoration(
                          color: _rideStatus == 'arrived'
                              ? Colors.green.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _rideStatus == 'arrived'
                                  ? Icons.check_circle
                                  : Icons.directions_car,
                              color: _rideStatus == 'arrived'
                                  ? Colors.green
                                  : Colors.blue.shade600,
                              size: Responsive.iconSize(context, 24),
                            ),
                            SizedBox(width: Responsive.spacing(context, 8)),
                            Text(
                              _rideStatus == 'arrived'
                                  ? 'Arrived at Pickup'
                                  : 'Arriving at Pickup...',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                                color: _rideStatus == 'arrived'
                                    ? Colors.green
                                    : Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 16)),

                      // Pickup Location
                      Container(
                        padding: EdgeInsets.all(Responsive.padding(context, 16)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.pickupAddress,
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, 16),
                                      fontWeight: FontWeight.w600,
                                      color: _appTheme.textColor,
                                    ),
                                  ),
                                  SizedBox(
                                      height: Responsive.spacing(context, 4)),
                                  Text(
                                    widget.pickupDetails,
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, 12),
                                      color: _appTheme.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.call,
                                color: Colors.black,
                                size: Responsive.iconSize(context, 28),
                              ),
                              onPressed: _handleCallCustomer,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 16)),

                      // Action Buttons
                      if (_rideStatus == 'arriving')
                        SizedBox(
                          width: double.infinity,
                          height: Responsive.hp(context, 6.5),
                          child: ElevatedButton(
                            onPressed: _handleArrivedAtPickup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Arrived at Pickup',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: Responsive.hp(context, 6.5),
                          child: ElevatedButton(
                            onPressed: _handleStartRide,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Start Ride',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 16),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Current Location Button
              Positioned(
                bottom: Responsive.hp(context, 35),
                right: Responsive.padding(context, 16),
                child: FloatingActionButton(
                  onPressed: () {
                    // Center to current location
                    if (_mapController != null && _currentLocation != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(_currentLocation!, 16.0),
                      );
                    }
                  },
                  backgroundColor: Colors.white,
                  mini: true,
                  child: _isLoadingLocation
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _appTheme.textColor,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.my_location,
                          color: _appTheme.textColor,
                          size: Responsive.iconSize(context, 24),
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

