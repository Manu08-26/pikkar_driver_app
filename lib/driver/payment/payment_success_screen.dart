import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../home/home_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String planTitle;
  final String planPrice;
  final String planDuration;
  final String paymentMethod;
  final String transactionId;
  final String validityStartDate;
  final String validityEndDate;

  const PaymentSuccessScreen({
    super.key,
    required this.planTitle,
    required this.planPrice,
    required this.planDuration,
    required this.paymentMethod,
    required this.transactionId,
    required this.validityStartDate,
    required this.validityEndDate,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

// Helper class to calculate GST (same as in payment screen)
class PriceCalculator {
  static const double gstRate = 0.18; // 18% GST
  
  static double extractAmount(String priceString) {
    String numericString = priceString.replaceAll(RegExp(r'[^\d]'), '');
    return double.parse(numericString);
  }
  
  static double calculateGST(double baseAmount) {
    return baseAmount * gstRate;
  }
  
  static double calculateTotal(double baseAmount) {
    return baseAmount + calculateGST(baseAmount);
  }
  
  static String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  final AppTheme _appTheme = AppTheme();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} at ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _copyTransactionId() {
    Clipboard.setData(ClipboardData(text: widget.transactionId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction ID copied to clipboard'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button, force user to use "Done" button
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Responsive.padding(context, 24)),
                  child: Column(
                    children: [
                      SizedBox(height: Responsive.spacing(context, 20)),

                      // Success Animation
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(Responsive.padding(context, 24)),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(Responsive.padding(context, 20)),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              size: Responsive.iconSize(context, 80),
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: Responsive.spacing(context, 32)),

                      // Success Message
                      Text(
                        'Payment Successful!',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 28),
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      SizedBox(height: Responsive.spacing(context, 12)),

                      Text(
                        'Your subscription is now active',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          color: _appTheme.textGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: Responsive.spacing(context, 8)),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.padding(context, 16),
                          vertical: Responsive.padding(context, 10),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.green.shade700,
                              size: Responsive.iconSize(context, 16),
                            ),
                            SizedBox(width: Responsive.spacing(context, 8)),
                            Text(
                              '${widget.validityStartDate} to ${widget.validityEndDate}',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Responsive.spacing(context, 40)),

                      // Invoice Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(Responsive.padding(context, 24)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Invoice Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'INVOICE',
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(context, 24),
                                        fontWeight: FontWeight.bold,
                                        color: _appTheme.textColor,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(height: Responsive.spacing(context, 4)),
                                    Text(
                                      _getCurrentDateTime(),
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(context, 12),
                                        color: _appTheme.textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.all(Responsive.padding(context, 8)),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.workspace_premium,
                                    color: Colors.green,
                                    size: Responsive.iconSize(context, 32),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: Responsive.spacing(context, 24)),
                            Divider(color: Colors.grey.shade300, thickness: 1),
                            SizedBox(height: Responsive.spacing(context, 20)),

                            // Transaction Details
                            _buildInvoiceRow('Transaction ID', widget.transactionId, isTransactionId: true),
                            _buildInvoiceRow('Payment Method', widget.paymentMethod),
                            _buildInvoiceRow('Status', 'Success', isStatus: true),
                            
                            SizedBox(height: Responsive.spacing(context, 20)),
                            Divider(color: Colors.grey.shade300, thickness: 1),
                            SizedBox(height: Responsive.spacing(context, 20)),

                            // Plan Details
                            Text(
                              'SUBSCRIPTION DETAILS',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 12),
                                fontWeight: FontWeight.bold,
                                color: _appTheme.textGrey,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 16)),

                            _buildInvoiceRow('Plan', widget.planTitle),
                            _buildInvoiceRow('Duration', widget.planDuration),
                            _buildInvoiceRow('Validity Start', widget.validityStartDate),
                            _buildInvoiceRow('Validity End', widget.validityEndDate),
                            _buildInvoiceRow('Commission', '0% on all rides'),

                            SizedBox(height: Responsive.spacing(context, 20)),
                            Divider(color: Colors.grey.shade300, thickness: 1),
                            SizedBox(height: Responsive.spacing(context, 20)),

                            // Payment Breakdown
                            Text(
                              'PAYMENT BREAKDOWN',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 12),
                                fontWeight: FontWeight.bold,
                                color: _appTheme.textGrey,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 16)),

                            _buildInvoiceRow('Plan Amount', widget.planPrice),
                            _buildInvoiceRow(
                              'GST (18%)',
                              PriceCalculator.formatAmount(
                                PriceCalculator.calculateGST(
                                  PriceCalculator.extractAmount(widget.planPrice)
                                )
                              ),
                            ),

                            SizedBox(height: Responsive.spacing(context, 16)),
                            Divider(color: Colors.grey.shade300, thickness: 2),
                            SizedBox(height: Responsive.spacing(context, 16)),

                            // Total Amount
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Paid',
                                  style: TextStyle(
                                    fontSize: Responsive.fontSize(context, 18),
                                    fontWeight: FontWeight.bold,
                                    color: _appTheme.textColor,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.padding(context, 16),
                                    vertical: Responsive.padding(context, 8),
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF6A11CB),
                                        const Color(0xFF2575FC),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    PriceCalculator.formatAmount(
                                      PriceCalculator.calculateTotal(
                                        PriceCalculator.extractAmount(widget.planPrice)
                                      )
                                    ),
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, 24),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: Responsive.spacing(context, 32)),

                      // Benefits Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(Responsive.padding(context, 20)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green.shade50,
                              Colors.blue.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.celebration,
                                  color: Colors.green,
                                  size: Responsive.iconSize(context, 24),
                                ),
                                SizedBox(width: Responsive.spacing(context, 12)),
                                Text(
                                  'You\'re all set!',
                                  style: TextStyle(
                                    fontSize: Responsive.fontSize(context, 18),
                                    fontWeight: FontWeight.bold,
                                    color: _appTheme.textColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Responsive.spacing(context, 16)),
                            _buildBenefitItem('Start accepting rides with 0% commission'),
                            _buildBenefitItem('Keep 100% of your earnings'),
                            _buildBenefitItem('Access to priority support'),
                            _buildBenefitItem('View detailed analytics'),
                          ],
                        ),
                      ),

                      SizedBox(height: Responsive.spacing(context, 24)),

                      // Download Invoice Button
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Invoice downloaded successfully'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.download,
                          size: Responsive.iconSize(context, 20),
                        ),
                        label: Text(
                          'Download Invoice',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 15),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _appTheme.brandRed,
                          side: BorderSide(color: _appTheme.brandRed, width: 2),
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.padding(context, 24),
                            vertical: Responsive.padding(context, 16),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      SizedBox(height: Responsive.spacing(context, 32)),
                    ],
                  ),
                ),
              ),

              // Bottom Done Button
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: Responsive.hp(context, 6.5),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to home screen and clear all previous routes
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start Earning',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: Responsive.spacing(context, 8)),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: Responsive.iconSize(context, 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isTransactionId = false, bool isStatus = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
              color: _appTheme.textGrey,
            ),
          ),
          SizedBox(width: Responsive.spacing(context, 16)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: isStatus ? Colors.green : _appTheme.textColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                if (isTransactionId) ...[
                  SizedBox(width: Responsive.spacing(context, 8)),
                  GestureDetector(
                    onTap: _copyTransactionId,
                    child: Icon(
                      Icons.copy,
                      size: Responsive.iconSize(context, 16),
                      color: _appTheme.brandRed,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(context, 10)),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: Responsive.iconSize(context, 20),
            color: Colors.green,
          ),
          SizedBox(width: Responsive.spacing(context, 12)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: _appTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

