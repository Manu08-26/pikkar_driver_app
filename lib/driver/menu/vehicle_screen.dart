import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
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
          'Vehicle',
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
            // Vehicle Image Placeholder
            Center(
              child: Container(
                width: double.infinity,
                height: Responsive.hp(context, 25),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.directions_car,
                  size: Responsive.iconSize(context, 80),
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 32)),

            // Vehicle Details
            Text(
              'Vehicle Details',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            _buildInfoTile('Vehicle Type', 'Sedan'),
            _buildInfoTile('Make & Model', 'Honda City'),
            _buildInfoTile('Registration Number', 'TS 09 XX 1234'),
            _buildInfoTile('Color', 'White'),
            _buildInfoTile('Year', '2020'),
            
            SizedBox(height: Responsive.spacing(context, 24)),

            // Document Status
            Text(
              'Documents',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            _buildDocumentTile('RC', 'Verified', true),
            _buildDocumentTile('Insurance', 'Verified', true),
            _buildDocumentTile('Permit', 'Verified', true),
            _buildDocumentTile('Fitness Certificate', 'Verified', true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
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
            label,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
              color: _appTheme.textGrey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: _appTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(String name, String status, bool isVerified) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.pending,
            color: isVerified ? Colors.green : Colors.orange,
            size: Responsive.iconSize(context, 24),
          ),
          SizedBox(width: Responsive.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: _appTheme.textColor,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 12),
                    color: isVerified ? Colors.green : Colors.orange,
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

