import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/models/ride_model.dart';
import '../../core/providers/ride_provider.dart';
import 'ride_navigation_screen.dart';

class RideRequestScreen extends StatefulWidget {
  final RideModel ride;

  const RideRequestScreen({
    super.key,
    required this.ride,
  });

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  final AppTheme _appTheme = AppTheme();
  GoogleMapController? _mapController;
  int _countdown = 15;
  Timer? _timer;
  Set<Marker> _markers = {};
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    _startCountdown();
    _setupMarkers();
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _setupMarkers() {
    final pickupLoc = LatLng(
      widget.ride.pickupLocation.latitude,
      widget.ride.pickupLocation.longitude,
    );
    final dropLoc = LatLng(
      widget.ride.dropoffLocation.latitude,
      widget.ride.dropoffLocation.longitude,
    );

    _markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickupLoc,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.ride.pickupLocation.address),
      ),
      Marker(
        markerId: const MarkerId('drop'),
        position: dropLoc,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.ride.dropoffLocation.address),
      ),
    };
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        _rejectRide();
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitMarkersInMap();
  }

  void _fitMarkersInMap() {
    if (_mapController != null && _markers.isNotEmpty) {
      final pickupLoc = LatLng(
        widget.ride.pickupLocation.latitude,
        widget.ride.pickupLocation.longitude,
      );
      final dropLoc = LatLng(
        widget.ride.dropoffLocation.latitude,
        widget.ride.dropoffLocation.longitude,
      );

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              pickupLoc.latitude < dropLoc.latitude
                  ? pickupLoc.latitude
                  : dropLoc.latitude,
              pickupLoc.longitude < dropLoc.longitude
                  ? pickupLoc.longitude
                  : dropLoc.longitude,
            ),
            northeast: LatLng(
              pickupLoc.latitude > dropLoc.latitude
                  ? pickupLoc.latitude
                  : dropLoc.latitude,
              pickupLoc.longitude > dropLoc.longitude
                  ? pickupLoc.longitude
                  : dropLoc.longitude,
            ),
          ),
          100,
        ),
      );
    }
  }

  Future<void> _acceptRide() async {
    setState(() {
      _isAccepting = true;
    });

    _timer?.cancel();
    
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final success = await rideProvider.acceptRide(widget.ride.id);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RideNavigationScreen(
            ride: widget.ride,
          ),
        ),
      );
    } else if (mounted) {
      setState(() {
        _isAccepting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rideProvider.errorMessage ?? 'Failed to accept ride'),
          backgroundColor: _appTheme.brandRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _rejectRide() {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    rideProvider.removePendingRide(widget.ride.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pickupLoc = LatLng(
      widget.ride.pickupLocation.latitude,
      widget.ride.pickupLocation.longitude,
    );

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
                  target: pickupLoc,
                  zoom: 12.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),

              // Countdown Timer
              Positioned(
                top: Responsive.hp(context, 30),
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: Responsive.wp(context, 35),
                    height: Responsive.wp(context, 35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: Responsive.wp(context, 32),
                          height: Responsive.wp(context, 32),
                          child: CircularProgressIndicator(
                            value: _countdown / 15,
                            strokeWidth: 6,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600,
                            ),
                          ),
                        ),
                        Text(
                          '$_countdown',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 36),
                            fontWeight: FontWeight.bold,
                            color: _appTheme.textColor,
                          ),
                        ),
                      ],
                    ),
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
                      // Distance and Fare
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Distance : ${widget.ride.distance.toStringAsFixed(1)}KM',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.w600,
                              color: _appTheme.textColor,
                            ),
                          ),
                          Text(
                            'Pay : ₹${(widget.ride.estimatedFare ?? 0).toStringAsFixed(0)}/-',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: _appTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.spacing(context, 20)),

                      // Pickup and Drop Locations
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
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: EdgeInsets.only(
                                      top: Responsive.padding(context, 4)),
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
                                        widget.ride.pickupLocation.address,
                                        style: TextStyle(
                                          fontSize:
                                              Responsive.fontSize(context, 16),
                                          fontWeight: FontWeight.w600,
                                          color: _appTheme.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              margin: EdgeInsets.only(
                                left: Responsive.padding(context, 5.5),
                                top: Responsive.padding(context, 4),
                                bottom: Responsive.padding(context, 4),
                              ),
                              color: Colors.grey.shade400,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: EdgeInsets.only(
                                      top: Responsive.padding(context, 4)),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: Responsive.spacing(context, 12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.ride.dropoffLocation.address,
                                        style: TextStyle(
                                          fontSize:
                                              Responsive.fontSize(context, 16),
                                          fontWeight: FontWeight.w600,
                                          color: _appTheme.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 20)),

                      // Action Buttons
                      Row(
                        children: [
                          // Cancel Button
                          Container(
                            width: Responsive.wp(context, 20),
                            height: Responsive.hp(context, 7),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: Responsive.iconSize(context, 32),
                                color: _appTheme.textColor,
                              ),
                              onPressed: _isAccepting ? null : _rejectRide,
                            ),
                          ),
                          SizedBox(width: Responsive.spacing(context, 16)),
                          // Accept Button
                          Expanded(
                            child: SizedBox(
                              height: Responsive.hp(context, 7),
                              child: ElevatedButton(
                                onPressed: _isAccepting ? null : _acceptRide,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isAccepting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Accept Ride',
                                            style: TextStyle(
                                              fontSize:
                                                  Responsive.fontSize(context, 18),
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(
                                              width: Responsive.spacing(context, 8)),
                                          Icon(
                                            Icons.double_arrow,
                                            color: Colors.white,
                                            size: Responsive.iconSize(context, 24),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Current Location Button
              Positioned(
                bottom: Responsive.hp(context, 45),
                right: Responsive.padding(context, 16),
                child: FloatingActionButton(
                  onPressed: () {
                    // Center to current location
                    _fitMarkersInMap();
                  },
                  backgroundColor: Colors.white,
                  mini: true,
                  child: Icon(
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
