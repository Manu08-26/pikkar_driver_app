import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class RefundPolicyScreen extends StatefulWidget {
  const RefundPolicyScreen({super.key});

  @override
  State<RefundPolicyScreen> createState() => _RefundPolicyScreenState();
}

class _RefundPolicyScreenState extends State<RefundPolicyScreen> {
  final AppTheme _appTheme = AppTheme();

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
          'Refund Policy',
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
            Text(
              'Last Updated: January 2024',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 12),
                color: _appTheme.textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 24)),

            _buildSection(
              'Subscription Refunds',
              'Our subscription refund policy:\n\n'
              '• No refunds for completed subscription periods\n'
              '• Partial refunds may be provided for technical issues\n'
              '• Refund requests must be submitted within 24 hours\n'
              '• Refunds processed within 7-10 business days\n'
              '• Refunds credited to original payment method',
            ),

            _buildSection(
              'Eligibility for Refunds',
              'You may be eligible for a refund if:\n\n'
              '• The app experienced prolonged technical issues\n'
              '• You were incorrectly charged\n'
              '• Service was unavailable in your area\n'
              '• Duplicate charges occurred\n'
              '• The subscription was purchased by mistake',
            ),

            _buildSection(
              'Non-Refundable Items',
              'The following are non-refundable:\n\n'
              '• Partial periods of unused subscription\n'
              '• Account closure or suspension due to policy violations\n'
              '• Earnings already transferred to your account\n'
              '• Service fees and processing charges',
            ),

            _buildSection(
              'Refund Process',
              'To request a refund:\n\n'
              '1. Contact support at refunds@pikkar.com\n'
              '2. Provide your transaction ID and reason\n'
              '3. Submit supporting documentation if needed\n'
              '4. Wait for review (usually 2-3 business days)\n'
              '5. Receive notification of approval/denial\n'
              '6. Approved refunds processed within 7-10 days',
            ),

            _buildSection(
              'Cancellation Policy',
              'Subscription cancellations:\n\n'
              '• You can cancel anytime from the app\n'
              '• Cancellation takes effect at period end\n'
              '• No pro-rated refunds for early cancellation\n'
              '• Access continues until subscription expires\n'
              '• No cancellation fees',
            ),

            _buildSection(
              'Chargebacks',
              'If you file a chargeback with your bank:\n\n'
              '• Your account may be suspended immediately\n'
              '• Access to platform will be restricted\n'
              '• Please contact us first to resolve issues\n'
              '• Chargebacks may affect future account status',
            ),

            _buildSection(
              'Contact Support',
              'For refund inquiries:\n\n'
              'Email: refunds@pikkar.com\n'
              'Phone: 1800-XXX-XXXX\n'
              'Support Hours: 9 AM - 6 PM (Mon-Sat)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: _appTheme.textColor,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 12)),
        Text(
          content,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 14),
            color: _appTheme.textGrey,
            height: 1.6,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 24)),
      ],
    );
  }
}

