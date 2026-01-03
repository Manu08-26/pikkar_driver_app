import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'package:intl/intl.dart';

class EarningsStatementScreen extends StatefulWidget {
  const EarningsStatementScreen({super.key});

  @override
  State<EarningsStatementScreen> createState() => _EarningsStatementScreenState();
}

class _EarningsStatementScreenState extends State<EarningsStatementScreen> {
  final AppTheme _appTheme = AppTheme();
  String _selectedPeriod = 'Weekly';
  DateTime _selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _selectedEndDate = DateTime.now();

  // Demo data based on selected period
  final Map<String, Map<String, dynamic>> _periodData = {
    'Weekly': {
      'totalEarnings': 3250.75,
      'totalRides': 45,
      'activeHours': 42.5,
      'avgPerRide': 72.24,
      'distance': 285.5,
      'peakHours': 18.5,
      'offPeakHours': 24.0,
      'cancelledRides': 3,
    },
    'Monthly': {
      'totalEarnings': 12450.50,
      'totalRides': 145,
      'activeHours': 168.5,
      'avgPerRide': 85.86,
      'distance': 1150.0,
      'peakHours': 72.0,
      'offPeakHours': 96.5,
      'cancelledRides': 8,
    },
    'Yearly': {
      'totalEarnings': 148500.0,
      'totalRides': 1680,
      'activeHours': 1950.0,
      'avgPerRide': 88.39,
      'distance': 13200.0,
      'peakHours': 840.0,
      'offPeakHours': 1110.0,
      'cancelledRides': 45,
    },
    'Custom': {
      'totalEarnings': 1250.50,
      'totalRides': 18,
      'activeHours': 16.5,
      'avgPerRide': 69.47,
      'distance': 112.5,
      'peakHours': 8.5,
      'offPeakHours': 8.0,
      'cancelledRides': 1,
    },
  };

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

  Map<String, dynamic> get _currentData => _periodData[_selectedPeriod]!;

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _selectedStartDate,
        end: _selectedEndDate,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _appTheme.brandRed,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
        _selectedPeriod = 'Custom';
      });
    }
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
          'Earnings Statement',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: _appTheme.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.download,
              color: _appTheme.textColor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Statement downloaded successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.padding(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filter
            _buildPeriodFilter(),
            SizedBox(height: Responsive.spacing(context, 16)),

            // Date Range Display/Selector
            _buildDateRangeSelector(),
            SizedBox(height: Responsive.spacing(context, 24)),

            // Summary Card
            _buildSummaryCard(),
            SizedBox(height: Responsive.spacing(context, 24)),

            // Activity Overview
            Text(
              'Activity Overview',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 12)),
            _buildActivityGrid(),
            SizedBox(height: Responsive.spacing(context, 24)),

            // Detailed Breakdown
            Text(
              'Detailed Breakdown',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 12)),
            _buildDetailedBreakdown(),
            SizedBox(height: Responsive.spacing(context, 24)),

            // Time Analysis
            Text(
              'Time Analysis',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 12)),
            _buildTimeAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeriodChip('Weekly'),
          SizedBox(width: Responsive.spacing(context, 8)),
          _buildPeriodChip('Monthly'),
          SizedBox(width: Responsive.spacing(context, 8)),
          _buildPeriodChip('Yearly'),
          SizedBox(width: Responsive.spacing(context, 8)),
          _buildPeriodChip('Custom'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        if (period == 'Custom') {
          _selectDateRange();
        } else {
          setState(() => _selectedPeriod = period);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context, 20),
          vertical: Responsive.padding(context, 10),
        ),
        decoration: BoxDecoration(
          color: isSelected ? _appTheme.brandRed : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (period == 'Custom')
              Padding(
                padding: EdgeInsets.only(right: Responsive.spacing(context, 6)),
                child: Icon(
                  Icons.calendar_today,
                  size: Responsive.iconSize(context, 14),
                  color: isSelected ? Colors.white : _appTheme.textGrey,
                ),
              ),
            Text(
              period,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _appTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            color: Colors.blue.shade700,
            size: Responsive.iconSize(context, 24),
          ),
          SizedBox(width: Responsive.spacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statement Period',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 12),
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 4)),
                Text(
                  _selectedPeriod == 'Custom'
                      ? '${_formatDate(_selectedStartDate)} - ${_formatDate(_selectedEndDate)}'
                      : _getPeriodDateRange(),
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    color: _appTheme.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedPeriod == 'Custom')
            IconButton(
              icon: Icon(
                Icons.edit_calendar,
                color: _appTheme.brandRed,
                size: Responsive.iconSize(context, 20),
              ),
              onPressed: _selectDateRange,
            ),
        ],
      ),
    );
  }

  String _getPeriodDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Weekly':
        final weekAgo = now.subtract(const Duration(days: 7));
        return '${_formatDate(weekAgo)} - ${_formatDate(now)}';
      case 'Monthly':
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return '${_formatDate(monthAgo)} - ${_formatDate(now)}';
      case 'Yearly':
        final yearAgo = DateTime(now.year - 1, now.month, now.day);
        return '${_formatDate(yearAgo)} - ${_formatDate(now)}';
      default:
        return '';
    }
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4CAF50),
            const Color(0xFF45A049),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Earnings',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  color: Colors.white.withOpacity(0.9),
                ),
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
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: Responsive.iconSize(context, 14),
                    ),
                    SizedBox(width: Responsive.spacing(context, 4)),
                    Text(
                      '0% Fee',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 11),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 8)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatCurrency(_currentData['totalEarnings']),
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 42),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),
          SizedBox(height: Responsive.spacing(context, 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat(
                'Rides',
                '${_currentData['totalRides']}',
                Icons.drive_eta,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryStat(
                'Avg/Ride',
                _formatCurrency(_currentData['avgPerRide']),
                Icons.trending_up,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryStat(
                'Hours',
                '${_currentData['activeHours'].toStringAsFixed(1)}',
                Icons.access_time,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: Responsive.iconSize(context, 24),
        ),
        SizedBox(height: Responsive.spacing(context, 6)),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 11),
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActivityCard(
                'Total Rides',
                '${_currentData['totalRides']}',
                Icons.local_taxi,
                Colors.blue,
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActivityCard(
                'Active Hours',
                '${_currentData['activeHours'].toStringAsFixed(1)} hrs',
                Icons.access_time,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, 12)),
        Row(
          children: [
            Expanded(
              child: _buildActivityCard(
                'Distance',
                '${_currentData['distance'].toStringAsFixed(1)} km',
                Icons.route,
                Colors.purple,
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 12)),
            Expanded(
              child: _buildActivityCard(
                'Cancelled',
                '${_currentData['cancelledRides']}',
                Icons.cancel,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: Responsive.iconSize(context, 28),
              ),
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 6)),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: color,
                  size: Responsive.iconSize(context, 12),
                ),
              ),
            ],
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
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildBreakdownItem(
            'Total Earnings',
            _formatCurrency(_currentData['totalEarnings']),
            Colors.green,
            isTotal: true,
          ),
          _buildBreakdownItem(
            'Total Rides × Avg. Rate',
            '${_currentData['totalRides']} × ${_formatCurrency(_currentData['avgPerRide'])}',
            Colors.blue,
          ),
          _buildBreakdownItem(
            'Platform Fee',
            '₹0.00 (0%)',
            Colors.orange,
          ),
          _buildBreakdownItem(
            'Bonuses & Incentives',
            _formatCurrency(_currentData['totalEarnings'] * 0.05),
            Colors.purple,
          ),
          _buildBreakdownItem(
            'Tips from Customers',
            _formatCurrency(_currentData['totalEarnings'] * 0.03),
            Colors.pink,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    String label,
    String value,
    Color color, {
    bool isTotal = false,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade300),
        ),
        color: isTotal ? color.withOpacity(0.1) : Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: Responsive.spacing(context, 12)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: _appTheme.textColor,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: isTotal ? color : _appTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysis() {
    final peakHours = _currentData['peakHours'];
    final offPeakHours = _currentData['offPeakHours'];
    final totalHours = peakHours + offPeakHours;
    final peakPercentage = (peakHours / totalHours * 100).toStringAsFixed(1);
    final offPeakPercentage = (offPeakHours / totalHours * 100).toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 20)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: Responsive.spacing(context, 8)),
                        Text(
                          'Peak Hours',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 14),
                            color: _appTheme.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, 8)),
                    Text(
                      '${peakHours.toStringAsFixed(1)} hrs ($peakPercentage%)',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: _appTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: Responsive.spacing(context, 8)),
                        Text(
                          'Off-Peak Hours',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 14),
                            color: _appTheme.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, 8)),
                    Text(
                      '${offPeakHours.toStringAsFixed(1)} hrs ($offPeakPercentage%)',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: _appTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: peakHours.toInt(),
                    child: Container(color: Colors.orange),
                  ),
                  Expanded(
                    flex: offPeakHours.toInt(),
                    child: Container(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          Container(
            padding: EdgeInsets.all(Responsive.padding(context, 12)),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.blue.shade700,
                  size: Responsive.iconSize(context, 20),
                ),
                SizedBox(width: Responsive.spacing(context, 8)),
                Expanded(
                  child: Text(
                    'Peak hours: 8AM-10AM, 5PM-8PM • Higher demand & earnings',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 12),
                      color: Colors.blue.shade700,
                    ),
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

