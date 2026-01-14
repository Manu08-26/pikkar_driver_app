import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'profile_screen.dart';
import 'vehicle_screen.dart';
import 'earnings_screen.dart';
import 'ride_history_screen.dart';
import 'subscription_screen.dart';
import 'refer_earn_screen.dart';
import 'help_support_screen.dart';
import 'my_route_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'refund_policy_screen.dart';
import '../auth/login_screen.dart';
import '../parcel/available_parcels_screen.dart';
import '../parcel/parcel_history_screen.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

class MenuDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  
  const MenuDrawer({super.key, required this.scaffoldKey});

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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: _appTheme.textColor,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 14),
            color: _appTheme.textGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: _appTheme.textGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Clear backend session + local tokens
              Provider.of<AuthProvider>(context, listen: false).logout().catchError((_) {});
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _appTheme.brandRed,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    final scaffoldKey = widget.scaffoldKey;
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((shouldReopenDrawer) {
      // If the screen returns true, reopen the drawer
      if (shouldReopenDrawer == true) {
        // Use post frame callback to ensure UI is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scaffoldKey.currentState?.openDrawer();
        });
      }
    });
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
                    icon: Icons.inventory_2_outlined,
                    title: 'Parcel Jobs',
                    onTap: () => _navigateToScreen(const AvailableParcelsScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.inventory_outlined,
                    title: 'Parcel History',
                    onTap: () => _navigateToScreen(const ParcelHistoryScreen()),
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
                  
                  Divider(height: 1, color: Colors.grey.shade300),
                  
                  // Policy Links
                  _buildMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => _navigateToScreen(const PrivacyPolicyScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () => _navigateToScreen(const TermsConditionsScreen()),
                  ),
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Refund Policy',
                    onTap: () => _navigateToScreen(const RefundPolicyScreen()),
                  ),
                  
                  Divider(height: 1, color: Colors.grey.shade300),
                  
                  // Logout
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: _handleLogout,
                    iconColor: _appTheme.brandRed,
                    textColor: _appTheme.brandRed,
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
    Color? iconColor,
    Color? textColor,
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
              color: iconColor ?? _appTheme.textGrey,
            ),
            SizedBox(width: Responsive.spacing(context, 16)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 16),
                  color: textColor ?? _appTheme.textColor,
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

