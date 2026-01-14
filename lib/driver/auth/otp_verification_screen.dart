import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import 'dart:async';
import '../registration/select_vehicle_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final AppTheme _appTheme = AppTheme();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  int _resendTimer = 30;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    _startResendTimer();
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _timer?.cancel();
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

  void _startResendTimer() {
    _resendTimer = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
          } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _handleOTPInput(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto verify when all fields are filled
    if (index == 5 && value.isNotEmpty) {
      String otp = _otpControllers.map((controller) => controller.text).join();
      if (otp.length == 6) {
        FocusScope.of(context).unfocus();
      _verifyOTP();
      }
    }
  }

  void _verifyOTP() {
    String otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      _showError('Please enter complete OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    _verifyWithFirebaseAndBackend(otp);
  }

  Future<void> _verifyWithFirebaseAndBackend(String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Firebase user not available');
      }

      final idToken = await user.getIdToken();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final ok = await authProvider.loginWithFirebase(idToken: idToken);

      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (!ok) {
        _showError(authProvider.errorMessage ?? 'Failed to login');
        return;
      }

      _showSuccess('Login successful!');

      // Navigate to select vehicle screen (driver onboarding)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SelectVehicleScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      _showError('Error verifying OTP: $e');
    }
  }

  void _resendOTP() {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });
    _startResendTimer();
    _showSuccess('OTP resent successfully');
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Title
                      Text(
                        'Enter OTP',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _appTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        'We\'ve sent a 6-digit OTP to +91 ${widget.phoneNumber}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _appTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // OTP Input Fields
                      Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                            width: 48,
                            height: 56,
                                child: TextField(
                                  controller: _otpControllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: TextStyle(
                                fontSize: 20,
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
                                        color: _appTheme.brandRed,
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
                      const SizedBox(height: 32),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : _verifyOTP,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _appTheme.brandRed,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: _appTheme.brandRed.withOpacity(0.6),
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Verify',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Resend OTP
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Didn\'t receive OTP? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _appTheme.textGrey,
                                ),
                              ),
                            ),
                            if (_canResend)
                              InkWell(
                                onTap: _resendOTP,
                                child: Text(
                                  'Resend',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _appTheme.brandRed,
                                  ),
                                ),
                              )
                            else
                              Flexible(
                                child: Text(
                                  'Resend in ${_resendTimer}s',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _appTheme.textGrey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
