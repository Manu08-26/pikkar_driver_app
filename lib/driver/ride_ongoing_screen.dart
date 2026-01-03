import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';
import 'ride_complete_screen.dart';

class RideOngoingScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropAddress;
  final String dropDetails;
  final double distance;
  final double fare;

  const RideOngoingScreen({
    super.key,
    required this.pickupAddress,
    required this.dropAddress,
    required this.dropDetails,
    required this.distance,
    required this.fare,
  });

  @override
  State<RideOngoingScreen> createState() => _RideOngoingScreenState();
}

class _RideOngoingScreenState extends State<RideOngoingScreen> {
  final AppTheme _appTheme = AppTheme();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  static const LatLng _dropLocation = LatLng(17.4239, 78.4738);

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
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

  void _setupMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('drop'),
        position: _dropLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.dropAddress),
      ),
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _handleEndRide() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RideCompleteScreen(
          pickupAddress: widget.pickupAddress,
          dropAddress: widget.dropAddress,
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
                initialCameraPosition: const CameraPosition(
                  target: _dropLocation,
                  zoom: 14.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),

              // Ride Status Banner
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context, 20),
                    vertical: Responsive.padding(context, 16),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade600,
                        Colors.green.shade500,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: Responsive.iconSize(context, 24),
                      ),
                      SizedBox(width: Responsive.spacing(context, 8)),
                      Text(
                        'Ride in Progress',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Distance',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 12),
                                  color: _appTheme.textGrey,
                                ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 4)),
                              Text(
                                '${widget.distance} KM',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 18),
                                  fontWeight: FontWeight.bold,
                                  color: _appTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Fare',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 12),
                                  color: _appTheme.textGrey,
                                ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 4)),
                              Text(
                                '₹${widget.fare.toStringAsFixed(0)}/-',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 18),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.spacing(context, 20)),

                      // Drop Location
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
                                    widget.dropAddress,
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, 16),
                                      fontWeight: FontWeight.w600,
                                      color: _appTheme.textColor,
                                    ),
                                  ),
                                  SizedBox(
                                      height: Responsive.spacing(context, 4)),
                                  Text(
                                    widget.dropDetails,
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
                                color: Colors.green,
                                size: Responsive.iconSize(context, 28),
                              ),
                              onPressed: _handleCallCustomer,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 20)),

                      // End Ride Button
                      SizedBox(
                        width: double.infinity,
                        height: Responsive.hp(context, 6.5),
                        child: ElevatedButton(
                          onPressed: _handleEndRide,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _appTheme.brandRed,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'End Ride',
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
                bottom: Responsive.hp(context, 32),
                right: Responsive.padding(context, 16),
                child: FloatingActionButton(
                  onPressed: () {
                    // Center to current location
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

