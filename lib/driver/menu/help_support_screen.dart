import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
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
          onPressed: () => Navigator.pop(context, true), // Return true to reopen drawer
        ),
        title: Text(
          'Help & Support',
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
            // Contact Options
            _buildContactCard(
              Icons.phone,
              'Call Us',
              '1800-XXX-XXXX',
              Colors.green,
              () {
                // Handle call
              },
            ),
            _buildContactCard(
              Icons.email,
              'Email Us',
              'support@pikkar.com',
              Colors.blue,
              () {
                // Handle email
              },
            ),
            _buildContactCard(
              Icons.chat,
              'Live Chat',
              'Chat with support team',
              Colors.orange,
              () {
                // Handle chat
              },
            ),
            
            SizedBox(height: Responsive.spacing(context, 32)),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            _buildFAQItem(
              'How do I go online?',
              'Tap the "Off Duty" toggle at the top of your home screen to start receiving ride requests.',
            ),
            _buildFAQItem(
              'How do I withdraw my earnings?',
              'Go to Earnings screen and tap on "Withdraw Earnings". Amount will be transferred to your registered bank account.',
            ),
            _buildFAQItem(
              'What documents do I need?',
              'You need a valid driving license, vehicle RC, insurance, and fitness certificate to drive with Pikkar.',
            ),
            _buildFAQItem(
              'How are rides assigned?',
              'Rides are assigned based on your location, availability, and driver rating.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.spacing(context, 16)),
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 12)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: Responsive.iconSize(context, 24),
                color: color,
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
                    subtitle,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      color: _appTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: Responsive.iconSize(context, 16),
              color: _appTheme.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontSize: Responsive.fontSize(context, 15),
          fontWeight: FontWeight.w600,
          color: _appTheme.textColor,
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.padding(context, 16),
            0,
            Responsive.padding(context, 16),
            Responsive.padding(context, 16),
          ),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
              color: _appTheme.textGrey,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

