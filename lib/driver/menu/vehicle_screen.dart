import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/providers/driver_provider.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final AppTheme _appTheme = AppTheme();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    _loadVehicleData();
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _loadVehicleData() async {
    setState(() => _isLoading = true);
    
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    await driverProvider.loadDriverFromStorage();
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
          'Vehicle',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<DriverProvider>(
              builder: (context, driverProvider, child) {
                final driver = driverProvider.driver;

                if (driver == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: Responsive.iconSize(context, 64),
                          color: Colors.grey,
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),
                        Text(
                          'No vehicle data available',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 16),
                            color: _appTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(Responsive.padding(context, 24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Image Placeholder
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: Responsive.hp(context, 25),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _appTheme.brandRed.withOpacity(0.1),
                                _appTheme.brandRed.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _appTheme.brandRed.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: Responsive.iconSize(context, 80),
                                color: _appTheme.brandRed,
                              ),
                              SizedBox(height: Responsive.spacing(context, 8)),
                              if (driver.vehicleType != null)
                                Text(
                                  driver.vehicleType!.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: Responsive.fontSize(context, 18),
                                    fontWeight: FontWeight.bold,
                                    color: _appTheme.brandRed,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 32)),

                      // Vehicle Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Vehicle Details',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: _appTheme.textColor,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.padding(context, 12),
                              vertical: Responsive.padding(context, 6),
                            ),
                            decoration: BoxDecoration(
                              color: driver.verificationStatus == 'verified'
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: driver.verificationStatus == 'verified'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  driver.verificationStatus == 'verified'
                                      ? Icons.verified
                                      : Icons.pending,
                                  size: Responsive.iconSize(context, 16),
                                  color: driver.verificationStatus == 'verified'
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                SizedBox(width: Responsive.spacing(context, 4)),
                                Text(
                                  driver.verificationStatus == 'verified' ? 'Verified' : 'Pending',
                                  style: TextStyle(
                                    fontSize: Responsive.fontSize(context, 12),
                                    fontWeight: FontWeight.w600,
                                    color: driver.verificationStatus == 'verified'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.spacing(context, 16)),

                      if (driver.vehicleType != null)
                        _buildInfoTile('Vehicle Type', driver.vehicleType!),
                      if (driver.vehicleModel != null)
                        _buildInfoTile('Make & Model', driver.vehicleModel!),
                      if (driver.vehicleNumber != null)
                        _buildInfoTile('Registration Number', driver.vehicleNumber!),
                      if (driver.vehicleColor != null)
                        _buildInfoTile('Color', driver.vehicleColor!),
                      if (driver.vehicleYear != null)
                        _buildInfoTile('Year', driver.vehicleYear.toString()),
                      
                      SizedBox(height: Responsive.spacing(context, 24)),

                      // Document Status
                      Text(
                        'Documents',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: _appTheme.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 16)),

                      _buildDocumentTile(
                        'Registration Certificate (RC)',
                        driver.verificationStatus == 'verified' ? 'Verified' : 'Pending Verification',
                        driver.verificationStatus == 'verified',
                      ),
                      if (driver.licenseNumber != null)
                        _buildDocumentTile(
                          'Driving License',
                          'DL: ${driver.licenseNumber}',
                          driver.verificationStatus == 'verified',
                        ),
                      _buildDocumentTile(
                        'Insurance',
                        driver.verificationStatus == 'verified' ? 'Verified' : 'Not Uploaded',
                        driver.verificationStatus == 'verified',
                      ),
                      _buildDocumentTile(
                        'Account Status',
                        driver.verificationStatus?.toUpperCase() ?? 'UNKNOWN',
                        driver.verificationStatus == 'verified',
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
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
      ),
    );
  }

  Widget _buildDocumentTile(String name, String status, bool isVerified) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? Colors.green.shade300 : Colors.orange.shade300,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.padding(context, 8)),
            decoration: BoxDecoration(
              color: isVerified ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isVerified ? Icons.check_circle : Icons.pending,
              color: Colors.white,
              size: Responsive.iconSize(context, 20),
            ),
          ),
          SizedBox(width: Responsive.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: _appTheme.textColor,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 2)),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 12),
                    color: isVerified ? Colors.green.shade700 : Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
