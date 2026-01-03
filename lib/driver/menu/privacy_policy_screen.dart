import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
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
          'Privacy Policy',
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
              'Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
              '• Personal information (name, email, phone number)\n'
              '• Vehicle information (registration, insurance details)\n'
              '• Location data while using the app\n'
              '• Payment and banking information\n'
              '• Photos and documents for verification',
            ),

            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to:\n\n'
              '• Provide and maintain our services\n'
              '• Process your ride requests and payments\n'
              '• Communicate with you about your account\n'
              '• Improve our services and user experience\n'
              '• Ensure safety and security\n'
              '• Comply with legal obligations',
            ),

            _buildSection(
              'Information Sharing',
              'We may share your information with:\n\n'
              '• Customers who book rides with you\n'
              '• Service providers who help us operate our business\n'
              '• Law enforcement when required by law\n'
              '• Other parties with your consent',
            ),

            _buildSection(
              'Data Security',
              'We implement appropriate security measures to protect your personal information. '
              'However, no method of transmission over the internet is 100% secure.',
            ),

            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
              '• Access your personal information\n'
              '• Correct inaccurate data\n'
              '• Request deletion of your data\n'
              '• Opt-out of marketing communications\n'
              '• File a complaint with regulatory authorities',
            ),

            _buildSection(
              'Contact Us',
              'If you have questions about this Privacy Policy, please contact us at:\n\n'
              'Email: privacy@pikkar.com\n'
              'Phone: 1800-XXX-XXXX',
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

