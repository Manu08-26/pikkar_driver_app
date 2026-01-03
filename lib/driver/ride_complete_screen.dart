import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';
import 'rate_customer_screen.dart';

class RideCompleteScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropAddress;
  final double distance;
  final double fare;

  const RideCompleteScreen({
    super.key,
    required this.pickupAddress,
    required this.dropAddress,
    required this.distance,
    required this.fare,
  });

  @override
  State<RideCompleteScreen> createState() => _RideCompleteScreenState();
}

class _RideCompleteScreenState extends State<RideCompleteScreen>
    with SingleTickerProviderStateMixin {
  final AppTheme _appTheme = AppTheme();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _handleDone() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RateCustomerScreen(
          customerName: 'Rahul Kumar',
          pickupAddress: widget.pickupAddress,
          dropAddress: widget.dropAddress,
          distance: widget.distance,
          fare: widget.fare,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, 24)),
              child: Column(
                children: [
                  SizedBox(height: Responsive.hp(context, 6)),

                  // Success Animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: Responsive.wp(context, 35),
                      height: Responsive.wp(context, 35),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: Responsive.wp(context, 26),
                        color: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 24)),

                  // Title
                  Text(
                    'Ride Completed!',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 26),
                      fontWeight: FontWeight.bold,
                      color: _appTheme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.spacing(context, 6)),
                  Text(
                    'You have successfully completed the ride',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 13),
                      color: _appTheme.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.spacing(context, 30)),

                // Earnings Card
                Container(
                  padding: EdgeInsets.all(Responsive.padding(context, 24)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade600,
                        Colors.green.shade500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'You Earned',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      Text(
                        '₹${widget.fare.toStringAsFixed(0)}/-',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 48),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 24)),

                // Ride Details
                Container(
                  padding: EdgeInsets.all(Responsive.padding(context, 18)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Distance', '${widget.distance} KM'),
                      SizedBox(height: Responsive.spacing(context, 14)),
                      _buildDetailRow('Pickup', widget.pickupAddress),
                      SizedBox(height: Responsive.spacing(context, 14)),
                      _buildDetailRow('Drop', widget.dropAddress),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 30)),

                // Done Button
                SizedBox(
                  width: double.infinity,
                  height: Responsive.hp(context, 6.5),
                  child: ElevatedButton(
                    onPressed: _handleDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 16),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 16)),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 14),
            color: _appTheme.textGrey,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: _appTheme.textColor,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
