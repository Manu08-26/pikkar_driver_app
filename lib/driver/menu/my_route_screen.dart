import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class MyRouteScreen extends StatefulWidget {
  const MyRouteScreen({super.key});

  @override
  State<MyRouteScreen> createState() => _MyRouteScreenState();
}

class _MyRouteScreenState extends State<MyRouteScreen> {
  final AppTheme _appTheme = AppTheme();
  final List<String> _savedRoutes = [
    'Hitec City → Banjara Hills',
    'Gachibowli → Secunderabad',
    'Kukatpally → Madhapur',
  ];

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
          'My Route',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.padding(context, 16)),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: Responsive.iconSize(context, 24),
                ),
                SizedBox(width: Responsive.spacing(context, 12)),
                Expanded(
                  child: Text(
                    'Set your preferred routes to get more rides on your way',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Routes List
          Expanded(
            child: _savedRoutes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route,
                          size: Responsive.iconSize(context, 64),
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),
                        Text(
                          'No saved routes',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 16),
                            color: _appTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(Responsive.padding(context, 16)),
                    itemCount: _savedRoutes.length,
                    itemBuilder: (context, index) {
                      return _buildRouteCard(_savedRoutes[index]);
                    },
                  ),
          ),

          // Add Route Button
          Padding(
            padding: EdgeInsets.all(Responsive.padding(context, 24)),
            child: SizedBox(
              width: double.infinity,
              height: Responsive.hp(context, 6.5),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Handle add route
                  _showAddRouteDialog();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add New Route',
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
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(String route) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.route,
            size: Responsive.iconSize(context, 24),
            color: Colors.black,
          ),
          SizedBox(width: Responsive.spacing(context, 16)),
          Expanded(
            child: Text(
              route,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: _appTheme.textColor,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: Responsive.iconSize(context, 24),
            ),
            onPressed: () {
              // Handle delete
            },
          ),
        ],
      ),
    );
  }

  void _showAddRouteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Add Route'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'From',
                hintText: 'Enter starting point',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'To',
                hintText: 'Enter destination',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle save
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

