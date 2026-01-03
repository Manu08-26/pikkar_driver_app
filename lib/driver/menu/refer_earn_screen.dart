import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  final AppTheme _appTheme = AppTheme();
  final String _referralCode = 'PIKKAR2024';

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

  void _copyReferralCode() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Referral code copied!'),
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
          onPressed: () => Navigator.pop(context, true), // Return true to reopen drawer
        ),
        title: Text(
          'Refer & Earn',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context, 24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reward Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.padding(context, 24)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade600,
                    Colors.orange.shade500,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: Responsive.iconSize(context, 64),
                    color: Colors.white,
                  ),
                  SizedBox(height: Responsive.spacing(context, 16)),
                  Text(
                    'Earn ₹500',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 32),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 8)),
                  Text(
                    'For each successful referral',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 32)),

            // Referral Code
            Text(
              'Your Referral Code',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 12)),
            
            Container(
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
                    _referralCode,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 20),
                      fontWeight: FontWeight.bold,
                      color: _appTheme.textColor,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    onPressed: _copyReferralCode,
                    icon: Icon(
                      Icons.copy,
                      color: _appTheme.brandRed,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 32)),

            // How it works
            Text(
              'How it works',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            _buildStep('1', 'Share your referral code', 'Send to your friends who want to become drivers'),
            _buildStep('2', 'They sign up', 'Your friend uses your code during registration'),
            _buildStep('3', 'Complete rides', 'They complete their first 10 rides'),
            _buildStep('4', 'Get rewarded', 'You both earn ₹500 bonus'),
            
            SizedBox(height: Responsive.spacing(context, 24)),

            // Share Button
            SizedBox(
              width: double.infinity,
              height: Responsive.hp(context, 6.5),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle share
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text(
                  'Share Now',
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
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Responsive.wp(context, 10),
            height: Responsive.wp(context, 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(width: Responsive.spacing(context, 16)),
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
                  description,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    color: _appTheme.textGrey,
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

