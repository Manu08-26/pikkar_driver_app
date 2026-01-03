import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../home/home_screen.dart';

class RateCustomerScreen extends StatefulWidget {
  final String customerName;
  final String pickupAddress;
  final String dropAddress;
  final double distance;
  final double fare;

  const RateCustomerScreen({
    super.key,
    required this.customerName,
    required this.pickupAddress,
    required this.dropAddress,
    required this.distance,
    required this.fare,
  });

  @override
  State<RateCustomerScreen> createState() => _RateCustomerScreenState();
}

class _RateCustomerScreenState extends State<RateCustomerScreen> {
  final AppTheme _appTheme = AppTheme();
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  
  final List<String> _quickFeedback = [
    'Polite & Friendly',
    'On Time',
    'Respectful',
    'Good Communication',
    'Clean',
    'Professional',
  ];
  
  final List<String> _selectedQuickFeedback = [];

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _feedbackController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _submitRating() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a rating'),
          backgroundColor: _appTheme.brandRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    // Show success message
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: Responsive.iconSize(context, 64),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),
            Text(
              'Thank you!',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: _appTheme.textColor,
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 8)),
            Text(
              'Your feedback has been submitted',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: _appTheme.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.padding(context, 12),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _skipRating() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: _appTheme.textColor,
            ),
            onPressed: _skipRating,
          ),
          title: Text(
            'Rate Customer',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: _appTheme.textColor,
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(Responsive.padding(context, 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Customer Info Card
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 16)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade600,
                      Colors.green.shade500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: Responsive.wp(context, 10),
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Icon(
                        Icons.person,
                        size: Responsive.iconSize(context, 32),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, 16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.customerName,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 6)),
                          Row(
                            children: [
                              Icon(
                                Icons.currency_rupee,
                                size: Responsive.iconSize(context, 14),
                                color: Colors.white.withOpacity(0.9),
                              ),
                              Text(
                                '${widget.fare.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 14),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: Responsive.spacing(context, 12)),
                              Icon(
                                Icons.route,
                                size: Responsive.iconSize(context, 14),
                                color: Colors.white.withOpacity(0.9),
                              ),
                              Text(
                                '${widget.distance} km',
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 14),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Responsive.spacing(context, 24)),

              // Rating Section
              Text(
                'How was your experience?',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: _appTheme.textColor,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 20)),

              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRating = index + 1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(context, 6),
                      ),
                      child: Icon(
                        index < _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        size: Responsive.iconSize(context, 52),
                        color: index < _selectedRating
                            ? Colors.amber
                            : Colors.grey.shade400,
                      ),
                    ),
                  );
                }),
              ),
              
              SizedBox(height: Responsive.spacing(context, 12)),
              
              if (_selectedRating > 0)
                Text(
                  _selectedRating == 5
                      ? 'Excellent!'
                      : _selectedRating == 4
                          ? 'Good!'
                          : _selectedRating == 3
                              ? 'Average'
                              : 'Could be better',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: _selectedRating >= 4
                        ? Colors.green
                        : _selectedRating == 3
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),

              const Spacer(),

              // Quick Feedback  
              Text(
                'Quick Feedback (Optional)',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: _appTheme.textGrey,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 10)),
              
              Wrap(
                alignment: WrapAlignment.center,
                spacing: Responsive.spacing(context, 6),
                runSpacing: Responsive.spacing(context, 6),
                children: _quickFeedback.take(4).map((feedback) {
                  final isSelected = _selectedQuickFeedback.contains(feedback);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedQuickFeedback.remove(feedback);
                        } else {
                          _selectedQuickFeedback.add(feedback);
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.padding(context, 12),
                        vertical: Responsive.padding(context, 6),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        feedback,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 12),
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.green
                              : _appTheme.textGrey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: Responsive.spacing(context, 24)),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skipRating,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _appTheme.textGrey,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.padding(context, 14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.spacing(context, 12)),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          vertical: Responsive.padding(context, 14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Submit Rating',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 15),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Responsive.spacing(context, 16)),
            ],
          ),
        ),
      ),
    );
  }
}

