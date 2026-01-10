import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/providers/ride_provider.dart';
import '../../core/models/ride_model.dart';
import '../ride/ride_detail_screen.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final AppTheme _appTheme = AppTheme();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    _loadRideHistory();
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _loadRideHistory() async {
    setState(() => _isLoading = true);
    
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    await rideProvider.fetchRideHistory();
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  int _calculateDuration(RideModel ride) {
    // Calculate duration from start and end time if available
    if (ride.startTime != null && ride.endTime != null) {
      return ride.endTime!.difference(ride.startTime!).inMinutes;
    }
    // Approximate based on distance (assuming avg 30 km/h)
    if (ride.distance != null) {
      return ((ride.distance! / 30) * 60).round();
    }
    return 0;
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
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          'Ride History',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: _appTheme.textColor,
            ),
            onPressed: _loadRideHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<RideProvider>(
              builder: (context, rideProvider, child) {
                final rideHistory = rideProvider.rideHistory;

                if (rideHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: Responsive.iconSize(context, 64),
                          color: Colors.grey,
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),
                        Text(
                          'No ride history yet',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 16),
                            color: _appTheme.textGrey,
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 8)),
                        Text(
                          'Your completed rides will appear here',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 14),
                            color: _appTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadRideHistory,
                  child: ListView.builder(
                    padding: EdgeInsets.all(Responsive.padding(context, 16)),
                    itemCount: rideHistory.length,
                    itemBuilder: (context, index) {
                      final ride = rideHistory[index];
                      return _buildRideCard(ride);
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRideCard(RideModel ride) {
    final isCompleted = ride.status == 'completed';
    final isCancelled = ride.status == 'cancelled';
    
    return GestureDetector(
      onTap: () {
        // Navigate to ride detail screen
        // Uncomment when RideDetailScreen is updated to use RideModel
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => RideDetailScreen(ride: ride),
        //   ),
        // );
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
                  _formatDate(ride.createdAt),
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
                    color: isCompleted
                        ? Colors.green.shade50
                        : isCancelled
                            ? Colors.red.shade50
                            : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ride.status?.toUpperCase() ?? 'UNKNOWN',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 10),
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? Colors.green
                          : isCancelled
                              ? Colors.red
                              : Colors.orange,
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
                Expanded(
                  child: Text(
                    ride.pickupLocation.address,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: _appTheme.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                Expanded(
                  child: Text(
                    ride.dropoffLocation.address,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: _appTheme.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      '${ride.distance?.toStringAsFixed(1) ?? '0'} km',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14),
                        color: _appTheme.textGrey,
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, 16)),
                    Icon(
                      Icons.access_time,
                      size: Responsive.iconSize(context, 16),
                      color: _appTheme.textGrey,
                    ),
                    SizedBox(width: Responsive.spacing(context, 4)),
                    Text(
                      '${_calculateDuration(ride)} min',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14),
                        color: _appTheme.textGrey,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${(ride.actualFare ?? ride.estimatedFare)?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            // Payment Method
            if (ride.paymentMethod != null) ...[
              SizedBox(height: Responsive.spacing(context, 8)),
              Row(
                children: [
                  Icon(
                    ride.paymentMethod == 'cash'
                        ? Icons.money
                        : Icons.credit_card,
                    size: Responsive.iconSize(context, 14),
                    color: _appTheme.textGrey,
                  ),
                  SizedBox(width: Responsive.spacing(context, 4)),
                  Text(
                    ride.paymentMethod!.toUpperCase(),
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 12),
                      color: _appTheme.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
