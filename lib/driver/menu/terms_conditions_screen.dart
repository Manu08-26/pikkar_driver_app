import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
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
          'Terms & Conditions',
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
              'Acceptance of Terms',
              'By accessing and using Pikkar Driver App, you accept and agree to be bound by the terms '
              'and provision of this agreement. If you do not agree to these terms, please do not use our services.',
            ),

            _buildSection(
              'Driver Requirements',
              'To use our platform as a driver, you must:\n\n'
              '• Be at least 18 years old\n'
              '• Have a valid driving license\n'
              '• Own or have legal access to a vehicle\n'
              '• Have valid vehicle insurance\n'
              '• Pass our background verification check\n'
              '• Maintain required documents',
            ),

            _buildSection(
              'Service Usage',
              'You agree to:\n\n'
              '• Provide accurate and truthful information\n'
              '• Maintain professionalism with customers\n'
              '• Follow all traffic laws and regulations\n'
              '• Keep your vehicle in good condition\n'
              '• Accept or reject ride requests in good faith\n'
              '• Not discriminate against customers',
            ),

            _buildSection(
              'Commission and Payments',
              'Pikkar charges a commission on each completed ride. Payment terms include:\n\n'
              '• Commission rates as per your subscription plan\n'
              '• Weekly payment settlements\n'
              '• Applicable taxes and deductions\n'
              '• Payment processing fees',
            ),

            _buildSection(
              'Account Suspension',
              'We reserve the right to suspend or terminate your account if you:\n\n'
              '• Violate these terms and conditions\n'
              '• Receive multiple customer complaints\n'
              '• Engage in fraudulent activities\n'
              '• Fail to maintain required documents\n'
              '• Violate safety guidelines',
            ),

            _buildSection(
              'Liability',
              'Pikkar is not liable for:\n\n'
              '• Accidents or damages during rides\n'
              '• Lost or stolen items\n'
              '• Disputes with customers\n'
              '• Vehicle maintenance or repairs\n'
              '• Third-party actions',
            ),

            _buildSection(
              'Changes to Terms',
              'We reserve the right to modify these terms at any time. Continued use of our services '
              'after changes constitutes acceptance of the modified terms.',
            ),

            _buildSection(
              'Contact Information',
              'For questions about these terms, contact us at:\n\n'
              'Email: legal@pikkar.com\n'
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

