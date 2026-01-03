import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';
import 'ride_ongoing_screen.dart';

class RideOTPScreen extends StatefulWidget {
  final String pickupAddress;
  final String dropAddress;
  final String dropDetails;
  final double distance;
  final double fare;

  const RideOTPScreen({
    super.key,
    required this.pickupAddress,
    required this.dropAddress,
    required this.dropDetails,
    required this.distance,
    required this.fare,
  });

  @override
  State<RideOTPScreen> createState() => _RideOTPScreenState();
}

class _RideOTPScreenState extends State<RideOTPScreen> {
  final AppTheme _appTheme = AppTheme();
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _handleOTPInput(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto verify when all fields are filled
    if (index == 3 && value.isNotEmpty) {
      String otp = _otpControllers.map((controller) => controller.text).join();
      if (otp.length == 4) {
        FocusScope.of(context).unfocus();
        _verifyOTP();
      }
    }
  }

  void _verifyOTP() {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 4) {
      _showError('Please enter complete OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    // Simulate OTP verification
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });

        // For demo, accept any 4-digit OTP
        // In production, verify with backend
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RideOngoingScreen(
              pickupAddress: widget.pickupAddress,
              dropAddress: widget.dropAddress,
              dropDetails: widget.dropDetails,
              distance: widget.distance,
              fare: widget.fare,
            ),
          ),
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _appTheme.brandRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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
            'Enter Ride OTP',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: _appTheme.textColor,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Responsive.padding(context, 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.spacing(context, 20)),

                // Icon
                Center(
                  child: Container(
                    width: Responsive.wp(context, 24),
                    height: Responsive.wp(context, 24),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: Responsive.iconSize(context, 48),
                      color: Colors.green,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 32)),

                // Title
                Center(
                  child: Text(
                    'Ask customer for OTP',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      color: _appTheme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 8)),

                // Description
                Center(
                  child: Text(
                    'Customer will provide a 4-digit OTP\nto start the ride',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      color: _appTheme.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 48)),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: Responsive.wp(context, 16),
                      height: Responsive.hp(context, 8),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 24),
                          fontWeight: FontWeight.bold,
                          color: _appTheme.textColor,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: _appTheme.iconBgColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _appTheme.dividerColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _appTheme.dividerColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _handleOTPInput(index, value),
                      ),
                    );
                  }),
                ),
                SizedBox(height: Responsive.spacing(context, 48)),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: Responsive.hp(context, 6.5),
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.green.withOpacity(0.6),
                    ),
                    child: _isVerifying
                        ? SizedBox(
                            width: Responsive.iconSize(context, 24),
                            height: Responsive.iconSize(context, 24),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Verify & Start Ride',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const Spacer(),

                // Help Text
                Center(
                  child: Text(
                    'OTP is provided by the customer',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 12),
                      color: _appTheme.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

