import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import 'dart:async';
import '../registration/select_vehicle_screen.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/socket_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int? forceResendingToken;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.forceResendingToken,
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
  String? _verificationId;
  int? _forceResendingToken;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    _verificationId = widget.verificationId;
    _forceResendingToken = widget.forceResendingToken;
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

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      _showError('Please enter complete OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    final verificationId = _verificationId;
    if (verificationId == null || verificationId.isEmpty) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      _showError('OTP session expired. Please resend OTP.');
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('Firebase user not found after verification');
      }

      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Firebase idToken not found after verification');
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.loginWithFirebaseIdToken(
        idToken: idToken,
        role: 'driver',
      );

      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (!success) {
        _showError(authProvider.errorMessage ?? 'Login failed');
        return;
      }

      _showSuccess('OTP Verified Successfully!');

      // Connect socket after backend login
      await SocketService().connect();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SelectVehicleScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      _showError(e.message ?? 'Invalid OTP. Please try again.');
      for (final c in _otpControllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      _showError('Error verifying OTP: $e');
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });
    _startResendTimer();
    final phone = widget.phoneNumber.trim();
    final fullPhone = '+91$phone';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        forceResendingToken: _forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          final code = e.code;
          final msg = (e.message ?? '').toLowerCase();
          final isNotAuthorized = code == 'app-not-authorized' ||
              msg.contains('not authorized') ||
              msg.contains('play_integrity_token');

          _showError(
            isNotAuthorized
                ? 'Firebase Phone Auth is not authorized for this app.\n'
                    'Ensure Firebase Console Android app matches:\n'
                    '- package: com.pikkar.partner\n'
                    '- SHA-1 + SHA-256 added\n'
                    'Then download android/app/google-services.json and rebuild.'
                : (e.message ?? 'Failed to resend OTP'),
          );
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          _verificationId = verificationId;
          _forceResendingToken = forceResendingToken;
          _showSuccess('OTP resent successfully');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showError('Failed to resend OTP: $e');
    }
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
