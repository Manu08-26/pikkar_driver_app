import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';
import 'earnings_statement_screen.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  final AppTheme _appTheme = AppTheme();
  String _selectedPeriod = 'Today';

  // Demo data
  final double totalEarnings = 12450.50;
  final int totalRides = 145;
  
  // Today's data
  final int todayRides = 8;
  final double todayEarnings = 1250.50;
  final double todayDistance = 45.5; // km
  final double todayOnlineHours = 6.5;
  final double lastRidePayment = 285.0;
  
  final double weeklyEarnings = 3250.75;
  final double monthlyEarnings = 12450.50;

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

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Earnings',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Earnings Card
            _buildHeroEarningsCard(),
            
            SizedBox(height: Responsive.spacing(context, 24)),

            // Quick Stats Grid
            _buildQuickStatsGrid(),

            SizedBox(height: Responsive.spacing(context, 24)),

            // Period Selector
            Row(
              children: [
                _buildPeriodChip('Today'),
                SizedBox(width: Responsive.spacing(context, 8)),
                _buildPeriodChip('Week'),
                SizedBox(width: Responsive.spacing(context, 8)),
                _buildPeriodChip('Month'),
              ],
            ),
            SizedBox(height: Responsive.spacing(context, 20)),

            // Earnings Breakdown
            Text(
              'Earnings Breakdown',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),

            _buildEarningTile('Total Rides', '15 rides', '₹2,800'),
            _buildEarningTile('Platform Fee', '0% Commission', '₹0'),
            _buildEarningTile('Bonus', 'Performance', '+ ₹180'),
            _buildEarningTile('Tips', 'From customers', '+ ₹130'),
            
            Divider(height: 32, color: Colors.grey.shade300),
            
            _buildEarningTile(
              'Net Earnings',
              'Total for ${_selectedPeriod.toLowerCase()}',
              '₹3,110',
              isHighlighted: true,
            ),
            
            // SizedBox(height: Responsive.spacing(context, 24)),

            // // Withdraw Button
            // SizedBox(
            //   width: double.infinity,
            //   height: Responsive.hp(context, 6.5),
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       // Handle withdrawal
            //     },
            //     icon: Icon(
            //       Icons.account_balance_wallet,
            //       color: Colors.white,
            //       size: Responsive.iconSize(context, 20),
            //     ),
            //     label: Text(
            //       'Withdraw Earnings',
            //       style: TextStyle(
            //         fontSize: Responsive.fontSize(context, 16),
            //         fontWeight: FontWeight.w600,
            //         color: Colors.white,
            //       ),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: _appTheme.brandRed,
            //       elevation: 0,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroEarningsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.padding(context, 24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF45A049),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Today's Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.padding(context, 8)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.today,
                      color: Colors.white,
                      size: Responsive.iconSize(context, 20),
                    ),
                  ),
                  SizedBox(width: Responsive.spacing(context, 8)),
                  Text(
                    'Today\'s Earnings',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 10),
                  vertical: Responsive.padding(context, 4),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  DateTime.now().toString().split(' ')[0],
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 12),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.spacing(context, 20)),

          // Today's Total Earnings
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: Responsive.iconSize(context, 32),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Earned',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 13),
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatCurrency(todayEarnings),
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 36),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.spacing(context, 20)),
          
          // Today's Stats Grid
          Container(
            padding: EdgeInsets.all(Responsive.padding(context, 16)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTodayStatItem(
                        'Rides Completed',
                        '$todayRides',
                        Icons.drive_eta,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildTodayStatItem(
                        'Distance',
                        '${todayDistance.toStringAsFixed(1)} km',
                        Icons.route,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.spacing(context, 12)),
                Divider(color: Colors.white.withOpacity(0.3), height: 1),
                SizedBox(height: Responsive.spacing(context, 12)),
                Row(
                  children: [
                    Expanded(
                      child: _buildTodayStatItem(
                        'Online Hours',
                        '${todayOnlineHours.toStringAsFixed(1)} hrs',
                        Icons.access_time,
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: _buildTodayStatItem(
                        'Last Ride',
                        _formatCurrency(lastRidePayment),
                        Icons.payment,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: Responsive.spacing(context, 16)),

          Row(
            children: [
              Icon(
                Icons.verified,
                color: Colors.white,
                size: Responsive.iconSize(context, 18),
              ),
              SizedBox(width: Responsive.spacing(context, 8)),
              Flexible(
                child: Text(
                  '0% Commission • Keep 100% of Your Earnings',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 12),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.spacing(context, 16)),

          // View Statement Button
          SizedBox(
            width: double.infinity,
            height: Responsive.hp(context, 5.5),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EarningsStatementScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.receipt_long,
                color: const Color(0xFF4CAF50),
                size: Responsive.iconSize(context, 20),
              ),
              label: Text(
                'View Detailed Statement',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: Responsive.iconSize(context, 28),
        ),
        SizedBox(height: Responsive.spacing(context, 8)),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 11),
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.spacing(context, 4)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }


  Widget _buildQuickStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Weekly',
            _formatCurrency(weeklyEarnings),
            Icons.calendar_view_week,
            const Color(0xFF2196F3),
          ),
        ),
        SizedBox(width: Responsive.spacing(context, 12)),
        Expanded(
          child: _buildStatCard(
            'Monthly',
            _formatCurrency(monthlyEarnings),
            Icons.calendar_month,
            const Color(0xFF9C27B0),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.padding(context, 8)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: Responsive.iconSize(context, 24),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 12)),
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 12),
              color: _appTheme.textGrey,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 4)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, 16),
          vertical: Responsive.padding(context, 8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? _appTheme.brandRed : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _appTheme.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildEarningTile(
    String title,
    String subtitle,
    String amount, {
    bool isHighlighted = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? Colors.green.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    fontWeight:
                        isHighlighted ? FontWeight.bold : FontWeight.w600,
                    color: _appTheme.textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 12),
                    color: _appTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.green : _appTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

