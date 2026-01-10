import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/driver_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppTheme _appTheme = AppTheme();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    _loadProfileData();
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    
    // Load user and driver data if not already loaded
    await authProvider.loadUserFromStorage();
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
          'Profile',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer2<AuthProvider, DriverProvider>(
              builder: (context, authProvider, driverProvider, child) {
                final user = authProvider.user;
                final driver = driverProvider.driver;

                if (user == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: Responsive.iconSize(context, 64),
                          color: Colors.grey,
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),
                        Text(
                          'No profile data available',
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
                    children: [
                      // Profile Picture
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: Responsive.wp(context, 32),
                              height: Responsive.wp(context, 32),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _appTheme.brandRed,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: Responsive.iconSize(context, 64),
                                color: Colors.grey.shade400,
                              ),
                            ),
                            if (driver != null)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(Responsive.padding(context, 6)),
                                  decoration: BoxDecoration(
                                    color: driver.verificationStatus == 'verified'
                                        ? Colors.green
                                        : Colors.orange,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    driver.verificationStatus == 'verified'
                                        ? Icons.verified
                                        : Icons.pending,
                                    size: Responsive.iconSize(context, 16),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 16)),

                      // Name and Rating
                      Text(
                        '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 24),
                          fontWeight: FontWeight.bold,
                          color: _appTheme.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (driver?.rating != null) ...[
                        SizedBox(height: Responsive.spacing(context, 8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: Responsive.iconSize(context, 20),
                            ),
                            SizedBox(width: Responsive.spacing(context, 4)),
                            Text(
                              '${driver!.rating?.toStringAsFixed(1)} Rating',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                                color: _appTheme.textGrey,
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 8)),
                            Text(
                              '•',
                              style: TextStyle(
                                color: _appTheme.textGrey,
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, 8)),
                            Text(
                              '${driver.totalRides ?? 0} Trips',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                                color: _appTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: Responsive.spacing(context, 32)),

                      // Profile Information
                      if (user.email != null)
                        _buildInfoTile('Email', user.email!),
                      if (user.phone != null)
                        _buildInfoTile('Phone', user.phone!),
                      if (driver?.licenseNumber != null)
                        _buildInfoTile('License Number', driver!.licenseNumber!),
                      if (driver?.vehicleType != null)
                        _buildInfoTile('Vehicle Type', driver!.vehicleType!),
                      if (driver?.vehicleNumber != null)
                        _buildInfoTile('Vehicle Number', driver!.vehicleNumber!),
                      if (driver?.vehicleColor != null)
                        _buildInfoTile('Color', driver!.vehicleColor!),
                      if (driver?.vehicleYear != null)
                        _buildInfoTile('Year', driver!.vehicleYear.toString()),
                      if (driver?.verificationStatus != null)
                        _buildInfoTile(
                          'Account Status',
                          driver!.verificationStatus!.toUpperCase(),
                          statusColor: driver.verificationStatus == 'verified'
                              ? Colors.green
                              : driver.verificationStatus == 'pending'
                                  ? Colors.orange
                                  : Colors.red,
                        ),

                      SizedBox(height: Responsive.spacing(context, 24)),

                      // Edit Profile Button
                      SizedBox(
                        width: double.infinity,
                        height: Responsive.hp(context, 6.5),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            ).then((_) => _loadProfileData());
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: Responsive.iconSize(context, 20),
                          ),
                          label: Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _appTheme.brandRed,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoTile(String label, String value, {Color? statusColor}) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 16)),
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor ?? Colors.grey.shade300,
          width: statusColor != null ? 2 : 1,
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
                color: statusColor ?? _appTheme.textColor,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
