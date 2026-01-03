import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';

class RideDetailScreen extends StatefulWidget {
  final Map<String, dynamic> rideData;

  const RideDetailScreen({
    super.key,
    required this.rideData,
  });

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  final AppTheme _appTheme = AppTheme();

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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ride Details',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share,
              color: _appTheme.textColor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Share feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earnings Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.padding(context, 24)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.shade600,
                    Colors.green.shade500,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Earnings',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 14),
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.padding(context, 10),
                          vertical: Responsive.padding(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.rideData['status'] ?? 'Completed',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 11),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.spacing(context, 8)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.rideData['amount'] ?? '₹0',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 48),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 16)),
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: Responsive.iconSize(context, 18),
                      ),
                      SizedBox(width: Responsive.spacing(context, 6)),
                      Flexible(
                        child: Text(
                          '0% Commission • You got 100%',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 12),
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.spacing(context, 24)),

            // Ride Information
            Text(
              'Ride Information',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            // Journey Details Card
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 20)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  // Pickup
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                      SizedBox(width: Responsive.spacing(context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup Location',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 12),
                                color: _appTheme.textGrey,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 4)),
                            Text(
                              widget.rideData['pickup'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 15),
                                fontWeight: FontWeight.w600,
                                color: _appTheme.textColor,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 4)),
                            Text(
                              widget.rideData['pickupTime'] ?? 'Time not available',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 12),
                                color: _appTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Drop
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _appTheme.brandRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: Responsive.spacing(context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Drop Location',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 12),
                                color: _appTheme.textGrey,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 4)),
                            Text(
                              widget.rideData['drop'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 15),
                                fontWeight: FontWeight.w600,
                                color: _appTheme.textColor,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 4)),
                            Text(
                              widget.rideData['dropTime'] ?? 'Time not available',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 12),
                                color: _appTheme.textGrey,
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

            SizedBox(height: Responsive.spacing(context, 24)),

            // Trip Details
            Text(
              'Trip Details',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Date & Time',
                    widget.rideData['date'] ?? 'N/A',
                    Icons.calendar_today,
                  ),
                  Divider(height: 32, color: Colors.grey.shade300),
                  _buildDetailRow(
                    'Distance Traveled',
                    widget.rideData['distance'] ?? 'N/A',
                    Icons.route,
                  ),
                  Divider(height: 32, color: Colors.grey.shade300),
                  _buildDetailRow(
                    'Duration',
                    widget.rideData['duration'] ?? '25 mins',
                    Icons.access_time,
                  ),
                  Divider(height: 32, color: Colors.grey.shade300),
                  _buildDetailRow(
                    'Payment Method',
                    widget.rideData['paymentMethod'] ?? 'Cash',
                    Icons.payment,
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.spacing(context, 24)),

            // Customer Details
            Text(
              'Customer Details',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 20)),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: Responsive.wp(context, 10),
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.person,
                      size: Responsive.iconSize(context, 32),
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(width: Responsive.spacing(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.rideData['customerName'] ?? 'Customer',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: _appTheme.textColor,
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 4)),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: Responsive.iconSize(context, 16),
                              color: Colors.amber,
                            ),
                            SizedBox(width: Responsive.spacing(context, 4)),
                            Text(
                              widget.rideData['customerRating'] ?? '4.5',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                                color: _appTheme.textColor,
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 8)),
                            Text(
                              '(${widget.rideData['customerTrips'] ?? '150'} trips)',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 12),
                                color: _appTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.phone,
                    color: Colors.blue.shade700,
                    size: Responsive.iconSize(context, 24),
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.spacing(context, 24)),

            // Fare Breakdown
            Text(
              'Fare Breakdown',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 16)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildFareRow('Base Fare', '₹50'),
                  SizedBox(height: Responsive.spacing(context, 12)),
                  _buildFareRow('Distance Charge', '₹180'),
                  SizedBox(height: Responsive.spacing(context, 12)),
                  _buildFareRow('Time Charge', '₹20'),
                  SizedBox(height: Responsive.spacing(context, 12)),
                  _buildFareRow('Service Tax', '₹0', subtitle: '(0%)'),
                  SizedBox(height: Responsive.spacing(context, 12)),
                  Divider(color: Colors.grey.shade400),
                  SizedBox(height: Responsive.spacing(context, 12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: _appTheme.textColor,
                        ),
                      ),
                      Text(
                        widget.rideData['amount'] ?? '₹250',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: Responsive.spacing(context, 24)),

            // Your Rating
            if (widget.rideData['yourRating'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Rating',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: _appTheme.textColor,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 16)),
                  Container(
                    padding: EdgeInsets.all(Responsive.padding(context, 16)),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < (widget.rideData['yourRating'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: Responsive.iconSize(context, 28),
                            );
                          }),
                        ),
                        if (widget.rideData['yourFeedback'] != null)
                          Padding(
                            padding: EdgeInsets.only(
                              top: Responsive.spacing(context, 12),
                            ),
                            child: Text(
                              widget.rideData['yourFeedback'],
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 14),
                                color: _appTheme.textGrey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 24)),
                ],
              ),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Support feature coming soon'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.support_agent,
                      size: Responsive.iconSize(context, 20),
                    ),
                    label: Text(
                      'Support',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _appTheme.brandRed,
                      side: BorderSide(color: _appTheme.brandRed),
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.padding(context, 14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, 12)),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Receipt downloaded'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.download,
                      size: Responsive.iconSize(context, 20),
                    ),
                    label: Text(
                      'Receipt',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.padding(context, 14),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Responsive.padding(context, 8)),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: Responsive.iconSize(context, 20),
            color: _appTheme.textGrey,
          ),
        ),
        SizedBox(width: Responsive.spacing(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 12),
                  color: _appTheme.textGrey,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: _appTheme.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFareRow(String label, String value, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: _appTheme.textColor,
              ),
            ),
            if (subtitle != null)
              Text(
                ' $subtitle',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 12),
                  color: _appTheme.textGrey,
                ),
              ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
      ],
    );
  }
}

