import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../core/theme/app_theme.dart';
import '../core/utils/responsive.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String planTitle;
  final String planPrice;
  final String planDuration;
  final String validityStartDate;
  final String validityEndDate;

  const PaymentScreen({
    super.key,
    required this.planTitle,
    required this.planPrice,
    required this.planDuration,
    required this.validityStartDate,
    required this.validityEndDate,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

// Helper class to calculate GST
class PriceCalculator {
  static const double gstRate = 0.18; // 18% GST
  
  static double extractAmount(String priceString) {
    // Extract number from string like "₹99" or "₹1,499"
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

class _PaymentScreenState extends State<PaymentScreen> {
  final AppTheme _appTheme = AppTheme();
  String? _selectedPaymentMethod;
  final TextEditingController _upiIdController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _upiIdController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _processPayment() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a payment method'),
          backgroundColor: _appTheme.brandRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == 'upi_id' && _upiIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter UPI ID'),
          backgroundColor: _appTheme.brandRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing and redirect to payment app
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        // Show payment processing dialog
        _showPaymentRedirectDialog();
      }
    });
  }

  void _showPaymentRedirectDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.open_in_new,
              size: 64,
              color: _appTheme.brandRed,
            ),
            const SizedBox(height: 20),
            Text(
              'Redirecting to ${_getPaymentMethodName()}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please complete the payment in the app',
              style: TextStyle(
                fontSize: 14,
                color: _appTheme.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

    // Simulate redirect and payment success
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // Close redirect dialog
        _showPaymentSuccessDialog();
      }
    });
  }

  void _showPaymentSuccessDialog() {
    // Generate transaction ID
    final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999)}';
    
    // Navigate to payment success screen with invoice
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          planTitle: widget.planTitle,
          planPrice: widget.planPrice,
          planDuration: widget.planDuration,
          paymentMethod: _getPaymentMethodName(),
          transactionId: transactionId,
          validityStartDate: widget.validityStartDate,
          validityEndDate: widget.validityEndDate,
        ),
      ),
    );
  }

  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 'phonepe':
        return 'PhonePe';
      case 'googlepay':
        return 'Google Pay';
      case 'paytm':
        return 'Paytm';
      case 'amazonpay':
        return 'Amazon Pay';
      case 'bhim':
        return 'BHIM UPI';
      case 'upi_id':
        return 'UPI App';
      default:
        return 'Payment App';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
          'Payment',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: _appTheme.textColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.padding(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  Container(
                    padding: EdgeInsets.all(Responsive.padding(context, 20)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF6A11CB),
                          const Color(0xFF2575FC),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.workspace_premium,
                              color: Colors.white,
                              size: Responsive.iconSize(context, 32),
                            ),
                            SizedBox(width: Responsive.spacing(context, 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order Summary',
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, 14),
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  SizedBox(height: Responsive.spacing(context, 4)),
                                  Text(
                                    widget.planTitle,
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, 22),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    widget.planDuration,
                                    style: TextStyle(
                                      fontSize: Responsive.fontSize(context, 14),
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),
                        Divider(color: Colors.white.withOpacity(0.3)),
                        SizedBox(height: Responsive.spacing(context, 16)),
                        
                        // Price Breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plan Amount',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 14),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              widget.planPrice,
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 16),
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.spacing(context, 8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GST (18%)',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 14),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              PriceCalculator.formatAmount(
                                PriceCalculator.calculateGST(
                                  PriceCalculator.extractAmount(widget.planPrice)
                                )
                              ),
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 16),
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Responsive.spacing(context, 12)),
                        Divider(color: Colors.white.withOpacity(0.3)),
                        SizedBox(height: Responsive.spacing(context, 12)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 16),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              PriceCalculator.formatAmount(
                                PriceCalculator.calculateTotal(
                                  PriceCalculator.extractAmount(widget.planPrice)
                                )
                              ),
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 28),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.spacing(context, 32)),

                  // Payment Methods Section
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: _appTheme.textColor,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 16)),

                  // UPI Apps
                  _buildPaymentMethodCard(
                    id: 'phonepe',
                    title: 'PhonePe',
                    subtitle: 'UPI, Wallet & Cards',
                    icon: Icons.phone_android,
                    color: const Color(0xFF5F259F),
                  ),
                  _buildPaymentMethodCard(
                    id: 'googlepay',
                    title: 'Google Pay',
                    subtitle: 'UPI Payment',
                    icon: Icons.payment,
                    color: const Color(0xFF4285F4),
                  ),
                  _buildPaymentMethodCard(
                    id: 'paytm',
                    title: 'Paytm',
                    subtitle: 'UPI, Wallet & Cards',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFF00BAF2),
                  ),
                  _buildPaymentMethodCard(
                    id: 'amazonpay',
                    title: 'Amazon Pay',
                    subtitle: 'UPI & Wallet',
                    icon: Icons.shopping_bag,
                    color: const Color(0xFFFF9900),
                  ),
                  _buildPaymentMethodCard(
                    id: 'bhim',
                    title: 'BHIM UPI',
                    subtitle: 'Unified Payment Interface',
                    icon: Icons.compare_arrows,
                    color: const Color(0xFF0066CC),
                  ),

                  SizedBox(height: Responsive.spacing(context, 16)),

                  // UPI ID Section
                  Text(
                    'Or Pay Using UPI ID',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: _appTheme.textColor,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 12)),

                  _buildUpiIdCard(),

                  SizedBox(height: Responsive.spacing(context, 24)),

                  // Features
                  Container(
                    padding: EdgeInsets.all(Responsive.padding(context, 16)),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.green,
                          size: Responsive.iconSize(context, 24),
                        ),
                        SizedBox(width: Responsive.spacing(context, 12)),
                        Expanded(
                          child: Text(
                            'Safe and secure payments powered by UPI',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 13),
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Responsive.spacing(context, 12)),

                  // Tax Info
                  Container(
                    padding: EdgeInsets.all(Responsive.padding(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: Responsive.iconSize(context, 20),
                        ),
                        SizedBox(width: Responsive.spacing(context, 12)),
                        Expanded(
                          child: Text(
                            'GST (18%) included in total amount',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 12),
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Pay Button
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
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _appTheme.brandRed,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: _appTheme.brandRed.withOpacity(0.6),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pay ${PriceCalculator.formatAmount(PriceCalculator.calculateTotal(PriceCalculator.extractAmount(widget.planPrice)))}',
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
    );
  }

  Widget _buildPaymentMethodCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedPaymentMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.padding(context, 12)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: Responsive.iconSize(context, 28),
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
                      fontWeight: FontWeight.bold,
                      color: _appTheme.textColor,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 2)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 13),
                      color: _appTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: Responsive.iconSize(context, 24),
              height: Responsive.iconSize(context, 24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: Responsive.iconSize(context, 16),
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiIdCard() {
    final isSelected = _selectedPaymentMethod == 'upi_id';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = 'upi_id';
        });
      },
      child: Container(
        padding: EdgeInsets.all(Responsive.padding(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _appTheme.brandRed : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.padding(context, 12)),
                  decoration: BoxDecoration(
                    color: _appTheme.brandRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.alternate_email,
                    color: _appTheme.brandRed,
                    size: Responsive.iconSize(context, 28),
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, 16)),
                Expanded(
                  child: Text(
                    'Enter UPI ID',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: _appTheme.textColor,
                    ),
                  ),
                ),
                Container(
                  width: Responsive.iconSize(context, 24),
                  height: Responsive.iconSize(context, 24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _appTheme.brandRed : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? _appTheme.brandRed : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: Responsive.iconSize(context, 16),
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
            if (isSelected) ...[
              SizedBox(height: Responsive.spacing(context, 16)),
              TextField(
                controller: _upiIdController,
                decoration: InputDecoration(
                  hintText: 'yourname@upi',
                  hintStyle: TextStyle(color: _appTheme.textGrey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _appTheme.brandRed, width: 2),
                  ),
                  contentPadding: EdgeInsets.all(Responsive.padding(context, 16)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

