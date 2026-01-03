import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';
import 'profile_screen.dart';
import 'vehicle_screen.dart';
import 'earnings_screen.dart';
import 'ride_history_screen.dart';
import 'subscription_screen.dart';
import 'refer_earn_screen.dart';
import 'help_support_screen.dart';
import 'my_route_screen.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
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

  void _navigateToScreen(Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with profile info
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 24)),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: Responsive.wp(context, 20),
                    height: Responsive.wp(context, 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: Responsive.iconSize(context, 40),
                      color: Colors.grey.shade400,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 12)),
                  // Name and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sri Akshay',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: _appTheme.textColor,
                        ),
                      ),
                      SizedBox(width: Responsive.spacing(context, 8)),
                      Icon(
                        Icons.star,
                        size: Responsive.iconSize(context, 18),
                        color: Colors.orange,
                      ),
                      SizedBox(width: Responsive.spacing(context, 4)),
                      Text(
                        '4.9',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: _appTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.spacing(context, 4)),
                  // Phone Number
                  Text(
                    '+91-99667 78855',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      color: _appTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: Colors.grey.shade300),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () => _navigateToScreen(const ProfileScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.directions_car_outlined,
                    title: 'Vehicle',
                    onTap: () => _navigateToScreen(const VehicleScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Earnings',
                    onTap: () => _navigateToScreen(const EarningsScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Ride History',
                    onTap: () => _navigateToScreen(const RideHistoryScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.card_membership_outlined,
                    title: 'Subscription',
                    onTap: () => _navigateToScreen(const SubscriptionScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Refer & Earn',
                    onTap: () => _navigateToScreen(const ReferEarnScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => _navigateToScreen(const HelpSupportScreen()),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: Colors.grey.shade300),
            
            // My Route at bottom
            _buildMenuItem(
              icon: Icons.route_outlined,
              title: 'My Route',
              onTap: () => _navigateToScreen(const MyRouteScreen()),
              showArrow: false,
              trailing: Icon(
                Icons.location_on_outlined,
                size: Responsive.iconSize(context, 24),
                color: _appTheme.textGrey,
              ),
            ),
            
            SizedBox(height: Responsive.spacing(context, 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, 24),
          vertical: Responsive.padding(context, 16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: Responsive.iconSize(context, 24),
              color: _appTheme.textGrey,
            ),
            SizedBox(width: Responsive.spacing(context, 16)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 16),
                  color: _appTheme.textColor,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: Responsive.iconSize(context, 16),
                color: _appTheme.textGrey,
              )
            else if (trailing != null)
              trailing,
          ],
        ),
      ),
    );
  }
}

