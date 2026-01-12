import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'otp_verification_screen.dart';
import '../registration/select_vehicle_screen.dart';
import '../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AppTheme _appTheme = AppTheme();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    // Request location permission after splash screen
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      // If denied forever, user needs to enable in settings
      if (permission == LocationPermission.deniedForever) {
        // Permission denied forever - user needs to enable in settings
        return;
      }
    } catch (e) {
      print('Error requesting location permission: $e');
    }
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _handleContinue() async {
    print('📲 Login Continue clicked');
    // Validate phone number
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      print('⚠️ Invalid phone input: "${_phoneController.text}"');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid phone number'),
          backgroundColor: _appTheme.brandRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final phone = _phoneController.text.trim();
    final fullPhone = '+91$phone';
    print('📨 Sending Firebase OTP to: $fullPhone');

    try {
      // Guard: if Firebase isn't initialized/configured, PhoneAuth will throw [core/no-app]
      if (Firebase.apps.isEmpty) {
        print('❌ Firebase not initialized (Firebase.apps is empty)');
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Firebase is not configured. Add android/app/google-services.json and restart the app.',
            ),
            backgroundColor: _appTheme.brandRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval on Android sometimes provides the credential.
          // We'll let the OTP screen handle manual entry in most cases.
          print('✅ Firebase verificationCompleted (auto-retrieval)');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Firebase verificationFailed');
          print('   code=${e.code}');
          print('   message=${e.message}');
          print('   stackTrace=${e.stackTrace}');
          if (!mounted) return;
          setState(() => _isLoading = false);

          // A very common setup issue:
          // - Firebase Console app entry doesn't match applicationId (package name)
          // - SHA-1/SHA-256 not added in Firebase Console
          // Which leads to: app-not-authorized / Invalid app info in play_integrity_token
          final code = e.code;
          final msg = (e.message ?? '').toLowerCase();
          final isNotAuthorized = code == 'app-not-authorized' ||
              msg.contains('not authorized') ||
              msg.contains('play_integrity_token');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isNotAuthorized
                    ? 'Firebase Phone Auth is not authorized for this app.\n'
                        'Fix in Firebase Console:\n'
                        '- Android package name must be: com.pikkar.partner\n'
                        '- Add SHA-1 and SHA-256 (debug keystore)\n'
                        '- Download a fresh android/app/google-services.json\n'
                        'Then: flutter clean && flutter pub get && flutter run'
                    : (e.message ?? 'Failed to send OTP'),
              ),
              backgroundColor: _appTheme.brandRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          print('✅ Firebase codeSent');
          print('   verificationId=$verificationId');
          print('   forceResendingToken=$forceResendingToken');
          if (!mounted) return;
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OTPVerificationScreen(
                phoneNumber: phone,
                verificationId: verificationId,
                forceResendingToken: forceResendingToken,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // No-op. User can still enter OTP manually.
          print('⏱️ Firebase codeAutoRetrievalTimeout');
          print('   verificationId=$verificationId');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('❌ Exception while sending Firebase OTP: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP: $e'),
          backgroundColor: _appTheme.brandRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                      const SizedBox(height: 60),

                      /// APP BRANDING
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/logo_red.png',
                              width: 150,
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  'PIKKAR',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: _appTheme.brandRed,
                                    letterSpacing: 2,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      /// LOGIN SECTION
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _appTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your phone number to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: _appTheme.textGrey,
                            ),
                          ),
                          const SizedBox(height: 32),

                          /// PHONE NUMBER INPUT
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _appTheme.iconBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _phoneFocusNode.hasFocus
                                    ? _appTheme.brandRed
                                    : _appTheme.dividerColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Country Code & Flag
                                
                                Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _appTheme.textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Divider
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: _appTheme.dividerColor,
                                ),
                                const SizedBox(width: 12),
                                // Phone Number Input
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    focusNode: _phoneFocusNode,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _appTheme.textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Phone number',
                                      hintStyle: TextStyle(
                                        color: _appTheme.textGrey,
                                        fontSize: 16,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                      counterText: '',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      /// CONTINUE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _appTheme.brandRed,
                            disabledBackgroundColor: _appTheme.brandRed.withOpacity(0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                            'Continue',
                            style: TextStyle(
                                    fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// DIVIDER
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: _appTheme.dividerColor,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: _appTheme.textGrey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: _appTheme.dividerColor,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// CONTINUE WITH GOOGLE BUTTON
                      _socialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Continue with Google',
                        onTap: () {
                          // Navigate to Select Vehicle screen after Google login
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SelectVehicleScreen(),
                            ),
                          );
                        },
                        isGoogle: true,
                      ),

                      const SizedBox(height: 40),

                      /// TERMS & PRIVACY POLICY
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: Text(
                            'By continuing, you agree to our Terms & Privacy Policy',
                            style: TextStyle(
                              fontSize: 12,
                              color: _appTheme.textGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
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

  Widget _socialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isGoogle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _appTheme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              // Google Logo
              Image.asset(
                'assets/google_logo.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to network image
                  return Image.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      // Final fallback to icon
                  return Icon(
                    Icons.g_mobiledata,
                    color: _appTheme.textColor,
                        size: 24,
                      );
                    },
                  );
                },
              )
            else
              Icon(
                icon,
                color: _appTheme.textColor,
                size: 24,
              ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _appTheme.textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
