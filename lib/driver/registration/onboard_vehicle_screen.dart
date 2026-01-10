import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
    // If both are under review, navigate to home after a delay
    if (_vehicleInfoStatus == 'under_review' &&
        _profileInfoStatus == 'under_review') {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.all(Responsive.padding(context, 32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: Responsive.iconSize(context, 64),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 24)),
              Text(
                'Application Submitted!',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 22),
                  fontWeight: FontWeight.bold,
                  color: _appTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.spacing(context, 12)),
              Text(
                'Your documents are under review. You\'ll be notified once approved.',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  color: _appTheme.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.spacing(context, 32)),
              SizedBox(
                width: double.infinity,
                height: Responsive.hp(context, 6),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _appTheme.brandRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
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
    );
  }

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    // Auto-navigate to home after 5 seconds in debug builds to speed up testing.
    if (kDebugMode) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      });
    }
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
    // Check if vehicle info is completed first
    if (_vehicleInfoStatus != 'under_review' && _vehicleInfoStatus != 'approved') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete Vehicle Information first'),
          backgroundColor: _appTheme.brandRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

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
        return 'Pending';
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'not_updated':
        return Icons.pending_outlined;
      case 'under_review':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending_outlined;
    }
  }

  double _getProgress() {
    int completed = 0;
    if (_vehicleInfoStatus == 'under_review' ||
        _vehicleInfoStatus == 'approved') completed++;
    if (_profileInfoStatus == 'under_review' ||
        _profileInfoStatus == 'approved') completed++;
    return completed / 2;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _getProgress();
    
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: _appTheme.brandRed,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Complete Your Profile',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.padding(context, 24)),
                decoration: BoxDecoration(
                  color: _appTheme.brandRed,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 32),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 8)),
                    Text(
                      'Complete all steps to start earning',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14),
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 20)),
                    // Progress Bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Responsive.padding(context, 20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Documents',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: _appTheme.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      Text(
                        'Please upload the following documents to verify your account',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 14),
                          color: _appTheme.textGrey,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 24)),

                      // Step 1: Vehicle Information
                      _buildModernStepCard(
                        stepNumber: 1,
                        title: 'Vehicle Information',
                        description: 'Upload your RC (Registration Certificate)',
                        status: _vehicleInfoStatus,
                        icon: Icons.directions_car,
                        onTap: _handleVehicleInfoTap,
                      ),
                      
                      SizedBox(height: Responsive.spacing(context, 16)),

                      // Step 2: Profile Information
                      _buildModernStepCard(
                        stepNumber: 2,
                        title: 'Profile Information',
                        description: 'Upload Aadhar & Driving License',
                        status: _profileInfoStatus,
                        icon: Icons.person,
                        onTap: _handleProfileInfoTap,
                      ),

                      SizedBox(height: Responsive.spacing(context, 24)),

                      // Info Card
                      Container(
                        padding: EdgeInsets.all(Responsive.padding(context, 16)),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: Responsive.iconSize(context, 24),
                            ),
                            SizedBox(width: Responsive.spacing(context, 12)),
                            Expanded(
                              child: Text(
                                'Your documents will be verified within 24-48 hours. You\'ll receive a notification once approved.',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 13),
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernStepCard({
    required int stepNumber,
    required String title,
    required String description,
    required String status,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isCompleted =
        status == 'under_review' || status == 'approved';
    final statusColor = _getStatusColor(status);
    
    // Check if this step is locked (Step 2 can't be accessed until Step 1 is done)
    final isLocked = stepNumber == 2 && 
        _vehicleInfoStatus != 'under_review' && 
        _vehicleInfoStatus != 'approved';

    return InkWell(
      onTap: isLocked ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          padding: EdgeInsets.all(Responsive.padding(context, 20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLocked
                  ? Colors.grey.shade300
                  : isCompleted
                      ? statusColor.withOpacity(0.3)
                      : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isCompleted
                    ? statusColor.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Step Number Badge
              Container(
                width: Responsive.iconSize(context, 56),
                height: Responsive.iconSize(context, 56),
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.shade100
                      : isCompleted
                          ? statusColor.withOpacity(0.1)
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isLocked
                      ? Icon(
                          Icons.lock,
                          color: Colors.grey.shade400,
                          size: Responsive.iconSize(context, 28),
                        )
                      : Icon(
                          icon,
                          color: isCompleted ? statusColor : _appTheme.textGrey,
                          size: Responsive.iconSize(context, 28),
                        ),
                ),
              ),

              SizedBox(width: Responsive.spacing(context, 16)),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Step $stepNumber',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 12),
                            fontWeight: FontWeight.w600,
                            color: isLocked
                                ? Colors.grey.shade400
                                : _appTheme.brandRed,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: Responsive.spacing(context, 8)),
                        if (isLocked)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.padding(context, 8),
                              vertical: Responsive.padding(context, 4),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: Responsive.iconSize(context, 12),
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: Responsive.spacing(context, 4)),
                                Text(
                                  'Locked',
                                  style: TextStyle(
                                    fontSize: Responsive.fontSize(context, 11),
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.padding(context, 8),
                              vertical: Responsive.padding(context, 4),
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(status),
                                  size: Responsive.iconSize(context, 12),
                                  color: statusColor,
                                ),
                                SizedBox(width: Responsive.spacing(context, 4)),
                                Text(
                                  _getStatusText(status),
                                  style: TextStyle(
                                    fontSize: Responsive.fontSize(context, 11),
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, 6)),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 16),
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? Colors.grey.shade400
                            : _appTheme.textColor,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 4)),
                    Text(
                      isLocked
                          ? 'Complete Step 1 first'
                          : description,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 13),
                        color: isLocked
                            ? Colors.grey.shade400
                            : _appTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                isLocked ? Icons.lock : Icons.arrow_forward_ios,
                color: isLocked ? Colors.grey.shade400 : _appTheme.textGrey,
                size: Responsive.iconSize(context, 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
