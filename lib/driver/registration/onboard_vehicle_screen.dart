import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'upload_rc_screen.dart';
import 'profile_info_screen.dart';
import '../home/home_screen.dart';

class OnboardVehicleScreen extends StatefulWidget {
  const OnboardVehicleScreen({super.key});

  @override
  State<OnboardVehicleScreen> createState() => _OnboardVehicleScreenState();
}

class _OnboardVehicleScreenState extends State<OnboardVehicleScreen> {
  final AppTheme _appTheme = AppTheme();
  
  // Status: 'not_updated', 'under_review', 'approved', 'rejected'
  String _vehicleInfoStatus = 'not_updated';
  String _profileInfoStatus = 'not_updated';

  void _checkApprovalStatus() {
    // If both are under review, simulate approval and navigate to home
    if (_vehicleInfoStatus == 'under_review' &&
        _profileInfoStatus == 'under_review') {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    
    // Auto-navigate to home screen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _handleVehicleInfoTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UploadRCScreen(),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          _vehicleInfoStatus = 'under_review';
        });
        _checkApprovalStatus();
      }
    });
  }

  void _handleProfileInfoTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileInfoScreen(),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          _profileInfoStatus = 'under_review';
        });
        _checkApprovalStatus();
      }
    });
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'not_updated':
        return 'Not Updated';
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Not Updated';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'not_updated':
        return _appTheme.textGrey;
      case 'under_review':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return _appTheme.brandRed;
      default:
        return _appTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              _appTheme.rtlEnabled ? Icons.arrow_forward : Icons.arrow_back,
              color: _appTheme.textColor,
              size: Responsive.iconSize(context, 24),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Onboard Vehicle',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: _appTheme.textColor,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context, 24),
              vertical: Responsive.padding(context, 24),
            ),
            child: Column(
              children: [
                // Vehicle Information Card
                _buildInfoCard(
                  title: 'Vehicle Information',
                  status: _vehicleInfoStatus,
                  onTap: _handleVehicleInfoTap,
                ),
                SizedBox(height: Responsive.spacing(context, 16)),
                // Profile Information Card
                _buildInfoCard(
                  title: 'Profile Information',
                  status: _profileInfoStatus,
                  onTap: _handleProfileInfoTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String status,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(Responsive.padding(context, 20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _appTheme.dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: _appTheme.textColor,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 4)),
                  Text(
                    _getStatusText(status),
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(status),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _appTheme.rtlEnabled
                  ? Icons.arrow_back_ios
                  : Icons.arrow_forward_ios,
              color: _appTheme.textGrey,
              size: Responsive.iconSize(context, 20),
            ),
          ],
        ),
      ),
    );
  }
}

