import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../ride/ride_detail_screen.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final AppTheme _appTheme = AppTheme();

  final List<Map<String, dynamic>> _rideHistory = [
    {
      'date': 'Today, 2:30 PM',
      'pickup': 'Hitec City',
      'drop': 'Banjara Hills',
      'distance': '12.5 km',
      'amount': '₹250',
      'status': 'Completed',
      'pickupTime': '2:30 PM',
      'dropTime': '3:05 PM',
      'duration': '35 mins',
      'paymentMethod': 'Cash',
      'customerName': 'Rahul Kumar',
      'customerRating': '4.8',
      'customerTrips': '245',
      'yourRating': 5,
      'yourFeedback': 'Great customer! Very polite and respectful.',
    },
    {
      'date': 'Today, 11:00 AM',
      'pickup': 'Gachibowli',
      'drop': 'Secunderabad',
      'distance': '18.2 km',
      'amount': '₹380',
      'status': 'Completed',
      'pickupTime': '11:00 AM',
      'dropTime': '11:45 AM',
      'duration': '45 mins',
      'paymentMethod': 'UPI',
      'customerName': 'Priya Sharma',
      'customerRating': '4.5',
      'customerTrips': '128',
      'yourRating': 4,
      'yourFeedback': 'Good experience overall.',
    },
    {
      'date': 'Yesterday, 6:45 PM',
      'pickup': 'Kukatpally',
      'drop': 'Madhapur',
      'distance': '8.5 km',
      'amount': '₹170',
      'status': 'Completed',
      'pickupTime': '6:45 PM',
      'dropTime': '7:10 PM',
      'duration': '25 mins',
      'paymentMethod': 'Cash',
      'customerName': 'Amit Patel',
      'customerRating': '4.2',
      'customerTrips': '89',
      'yourRating': 3,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: _appTheme.textColor,
          ),
          onPressed: () => Navigator.pop(context, true), // Return true to reopen drawer
        ),
        title: Text(
          'Ride History',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        itemCount: _rideHistory.length,
        itemBuilder: (context, index) {
          final ride = _rideHistory[index];
          return _buildRideCard(ride);
        },
      ),
    );
  }

  Widget _buildRideCard(Map<String, dynamic> ride) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideDetailScreen(rideData: ride),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.spacing(context, 16)),
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ride['date'],
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 12),
                  color: _appTheme.textGrey,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 8),
                  vertical: Responsive.padding(context, 4),
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ride['status'],
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 10),
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 12)),

          // Pickup
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 8)),
              Text(
                ride['pickup'],
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: _appTheme.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 8)),

          // Drop
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _appTheme.brandRed,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 8)),
              Text(
                ride['drop'],
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: _appTheme.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 12)),
          
          Divider(color: Colors.grey.shade300),
          
          SizedBox(height: Responsive.spacing(context, 12)),

          // Distance and Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.route,
                    size: Responsive.iconSize(context, 16),
                    color: _appTheme.textGrey,
                  ),
                  SizedBox(width: Responsive.spacing(context, 4)),
                  Text(
                    ride['distance'],
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      color: _appTheme.textGrey,
                    ),
                  ),
                ],
              ),
              Text(
                ride['amount'],
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

