import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../payment/payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final AppTheme _appTheme = AppTheme();
  int _selectedPlanIndex = -1;
  int _currentPage = 0; // Start with Free plan (first)
  
  late final PageController _pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.85, // Show partial views of adjacent cards
  );

  // Demo active plan data - Set hasActivePlan to true to show active plan
  final bool hasActivePlan = true; // Change to false to show hero section
  final String activePlanName = 'Starter Welcome';
  final String activePlanDuration = '30 Days Free';
  final double totalEarnings = 12450.50;
  
  // Free plan for new drivers
  final DateTime driverRegistrationDate = DateTime.now().subtract(const Duration(days: 5));
  final int freePlanDaysRemaining = 25; // 30 days - 5 days elapsed
  final DateTime planStartDate = DateTime.now().subtract(const Duration(days: 5));
  final DateTime planEndDate = DateTime.now().add(const Duration(days: 25));

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
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
          onPressed: () => Navigator.pop(context, true), // Return true to reopen drawer
        ),
        title: Text(
          'Subscription Plans',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: _appTheme.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Active Plan Card or Header
            if (hasActivePlan)
              _buildActivePlanCard()
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.padding(context, 32)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6A11CB),
                      const Color(0xFF2575FC),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(Responsive.padding(context, 16)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        size: Responsive.iconSize(context, 48),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 20)),
                    Text(
                      'Drive More, Earn More',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 28),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.spacing(context, 12)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.padding(context, 20),
                        vertical: Responsive.padding(context, 10),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: _appTheme.brandRed,
                            size: Responsive.iconSize(context, 20),
                          ),
                          SizedBox(width: Responsive.spacing(context, 8)),
                          Text(
                            '0% Commission on Every Ride',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: _appTheme.brandRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 16)),
                    Text(
                      'Choose a plan and keep 100% of your earnings',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14),
                        color: Colors.white.withOpacity(0.95),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            SizedBox(height: Responsive.spacing(context, 24)),

            // Current Plan Card (Demo - Would show if user has active subscription)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 20)),
              child: _buildCurrentPlanCard(),
            ),

            SizedBox(height: Responsive.spacing(context, 24)),

            // Plans Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your Plan',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 22),
                          fontWeight: FontWeight.bold,
                          color: _appTheme.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      Text(
                        'Swipe to explore flexible plans',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 14),
                          color: _appTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 24)),

                // Carousel View for Plans
                SizedBox(
                  height: Responsive.hp(context, 65), // Increased from 58 to 65 to fix overflow
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      // Free Plan - NEW DRIVERS
                      _buildFreePlanCard(),
                      
                      // Quick Start Plan
                      _buildProfessionalPlanCard(
                        index: 1,
                        title: 'Quick Start',
                        duration: 'Day Pass',
                        price: '₹99',
                        originalPrice: '₹199',
                        discount: '50% OFF',
                        benefits: [
                            '0% commission on rides',
                          'Valid for 1 day',
                          'Unlimited rides',
                          
                          '24/7 priority support',
                          
                        ],
                        color: const Color(0xFF2196F3),
                        icon: Icons.flash_on,
                      ),

                      // Weekly Plan - RECOMMENDED
                      _buildProfessionalPlanCard(
                        index: 2,
                        title: 'Power Drive',
                        duration: '7 Days',
                        price: '₹499',
                        originalPrice: '₹999',
                        discount: '50% OFF',
                        benefits: [
                            '0% commission on rides',
                          'Valid for 7 days',
                          'Unlimited rides',
                          
                          '24/7 priority support',
                        ],
                        color: const Color(0xFF4CAF50),
                        icon: Icons.electric_bolt,
                        isRecommended: true,
                      ),

                      // Monthly Plan - BEST VALUE
                      _buildProfessionalPlanCard(
                        index: 3,
                        title: 'Elite Partner',
                        duration: '30 Days',
                        price: '₹1,499',
                        originalPrice: '₹3,999',
                        discount: '62% OFF',
                        benefits: [
                          '0% commission on rides',
                          'Valid for 30 days',
                          'Unlimited rides',
                          
                          '24/7 priority support',
                         
                          
                        ],
                        color: const Color(0xFF9C27B0),
                        icon: Icons.stars,
                        isBestValue: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Responsive.spacing(context, 20)),

                // Page Indicators (Dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 4)),
                      height: Responsive.spacing(context, 8),
                      width: _currentPage == index 
                          ? Responsive.spacing(context, 24) 
                          : Responsive.spacing(context, 8),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFF6A11CB)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
                ),

                SizedBox(height: Responsive.spacing(context, 32)),

                // Features Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 20)),
                  child: _buildFeaturesSection(),
                ),

                SizedBox(height: Responsive.spacing(context, 40)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    // Demo values - In production, fetch from user's actual subscription
    final hasActivePlan = false; // Set to true to show active plan
    
    if (!hasActivePlan) {
      return const SizedBox.shrink(); // Don't show if no active plan
    }

    // Demo data (unreachable when hasActivePlan is false - intentional for demo)
    // ignore: dead_code
    final planTitle = 'Weekly';
    // ignore: dead_code
    final validityStart = _formatDate(DateTime.now().subtract(const Duration(days: 2)));
    // ignore: dead_code
    final validityEnd = _formatDate(DateTime.now().add(const Duration(days: 5)));
    // ignore: dead_code
    final remainingDays = 5;
    
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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 10)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: Responsive.iconSize(context, 28),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Plan',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14),
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      planTitle,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 12),
                  vertical: Responsive.padding(context, 6),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 12),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
          SizedBox(height: Responsive.spacing(context, 16)),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Validity Period',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 12),
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 4)),
                    Text(
                      '$validityStart - $validityEnd',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      '$remainingDays',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 24),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Days Left',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 11),
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: Responsive.iconSize(context, 18),
              ),
              SizedBox(width: Responsive.spacing(context, 8)),
              Text(
                '0% Commission Active',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalPlanCard({
    required int index,
    required String title,
    required String duration,
    required String price,
    required String originalPrice,
    required String discount,
    required List<String> benefits,
    required Color color,
    required IconData icon,
    bool isRecommended = false,
    bool isBestValue = false,
  }) {
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Responsive.spacing(context, 8),
          vertical: Responsive.spacing(context, 8),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(Responsive.padding(context, 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(Responsive.padding(context, 12)),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
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
                                fontSize: Responsive.fontSize(context, 24),
                                fontWeight: FontWeight.bold,
                                color: _appTheme.textColor,
                              ),
                            ),
                            Text(
                              duration,
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 14),
                                color: _appTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: EdgeInsets.all(Responsive.padding(context, 8)),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: Responsive.iconSize(context, 20),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: Responsive.spacing(context, 20)),

                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 36),
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      SizedBox(width: Responsive.spacing(context, 12)),
                      Padding(
                        padding: EdgeInsets.only(bottom: Responsive.padding(context, 6)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              originalPrice,
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 16),
                                color: _appTheme.textGrey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.padding(context, 8),
                                vertical: Responsive.padding(context, 2),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                discount,
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 11),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Responsive.spacing(context, 20)),
                  Divider(color: Colors.grey.shade200),
                  SizedBox(height: Responsive.spacing(context, 16)),

                  // Benefits
                  ...benefits.map((benefit) => Padding(
                        padding: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: Responsive.iconSize(context, 20),
                              color: color,
                            ),
                            SizedBox(width: Responsive.spacing(context, 12)),
                            Expanded(
                              child: Text(
                                benefit,
                                style: TextStyle(
                                  fontSize: Responsive.fontSize(context, 14),
                                  color: _appTheme.textColor,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  SizedBox(height: Responsive.spacing(context, 20)),

                  // Subscribe Button
                  SizedBox(
                    width: double.infinity,
                    height: Responsive.hp(context, 6),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPlanIndex = index;
                        });
                        // Navigate to payment screen
                        _navigateToPayment(title, price, duration);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? color : color.withOpacity(0.9),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isSelected ? 'Selected - Subscribe Now' : 'Select Plan',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Badge
            if (isRecommended || isBestValue)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.padding(context, 16),
                    vertical: Responsive.padding(context, 8),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isRecommended
                          ? [Colors.green, Colors.green.shade700]
                          : [Colors.orange, Colors.orange.shade700],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRecommended ? Icons.star : Icons.local_fire_department,
                        size: Responsive.iconSize(context, 14),
                        color: Colors.white,
                      ),
                      SizedBox(width: Responsive.spacing(context, 4)),
                      Text(
                        isRecommended ? 'RECOMMENDED' : 'BEST VALUE',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 11),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.black,
                size: Responsive.iconSize(context, 28),
              ),
              SizedBox(width: Responsive.spacing(context, 12)),
              Text(
                'Why Subscribe?',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: _appTheme.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 20)),
          _buildFeatureItem(
            Icons.money_off,
            'Zero Commission',
            'Keep 100% of your ride earnings',
          ),
          _buildFeatureItem(
            Icons.trending_up,
            'Maximize Earnings',
            'Earn more with every trip you complete',
          ),
          _buildFeatureItem(
            Icons.support_agent,
            'Priority Support',
            '24/7 dedicated support for subscribers',
          ),
          _buildFeatureItem(
            Icons.analytics,
            'Advanced Analytics',
            'Track your performance and earnings',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(context, 16)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.padding(context, 10)),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: Responsive.iconSize(context, 24),
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
                SizedBox(height: Responsive.spacing(context, 4)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 13),
                    color: _appTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime _calculateStartDate() {
    return DateTime.now();
  }

  DateTime _calculateEndDate(String planTitle) {
    DateTime startDate = _calculateStartDate();
    switch (planTitle) {
      case 'Quick Start':
        return startDate.add(const Duration(days: 1));
      case 'Power Drive':
        return startDate.add(const Duration(days: 7));
      case 'Elite Partner':
        return startDate.add(const Duration(days: 30));
      default:
        return startDate.add(const Duration(days: 30));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  Widget _buildFreePlanCard() {
    final freeTrialEndDate = driverRegistrationDate.add(const Duration(days: 30));
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(context, 8),
        vertical: Responsive.spacing(context, 8),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFFFA500), // Orange
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context, 24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(Responsive.padding(context, 12)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: Responsive.iconSize(context, 28),
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, 16)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Starter Welcome',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 24),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'New Driver Special',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 14),
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: Responsive.spacing(context, 20)),

                // Price Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'FREE',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 42),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, 12)),
                    Padding(
                      padding: EdgeInsets.only(bottom: Responsive.padding(context, 8)),
                      child: Text(
                        '30 Days',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 16),
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: Responsive.spacing(context, 20)),
                Divider(color: Colors.white.withOpacity(0.3)),
                SizedBox(height: Responsive.spacing(context, 16)),

                // Days Remaining Banner
                Container(
                  padding: EdgeInsets.all(Responsive.padding(context, 16)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: Responsive.iconSize(context, 32),
                      ),
                      SizedBox(width: Responsive.spacing(context, 16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$freePlanDaysRemaining Days Remaining',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 18),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 4)),
                            Text(
                              'Expires on ${_formatDate(freeTrialEndDate)}',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 13),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Responsive.spacing(context, 20)),

                // Benefits
                ...[
                  '0% commission on rides',
                  'Valid for 30 days',
                  'Unlimited rides',
                  
                  'Perfect to get started',
                ].map((benefit) => Padding(
                      padding: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: Responsive.iconSize(context, 20),
                            color: Colors.white,
                          ),
                          SizedBox(width: Responsive.spacing(context, 12)),
                          Expanded(
                            child: Text(
                              benefit,
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 14),
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                SizedBox(height: Responsive.spacing(context, 20)),

                // Active Status Button (Non-clickable)
                Container(
                  width: double.infinity,
                  height: Responsive.hp(context, 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: const Color(0xFFFFD700),
                          size: Responsive.iconSize(context, 24),
                        ),
                        SizedBox(width: Responsive.spacing(context, 8)),
                        Text(
                          'Currently Active',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),

          // NEW Badge
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context, 16),
                vertical: Responsive.padding(context, 8),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.red.shade700],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    size: Responsive.iconSize(context, 14),
                    color: Colors.white,
                  ),
                  SizedBox(width: Responsive.spacing(context, 4)),
                  Text(
                    'NEW DRIVER',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 11),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard() {
    final remainingDays = planEndDate.difference(DateTime.now()).inDays;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(Responsive.padding(context, 20)),
      padding: EdgeInsets.all(Responsive.padding(context, 24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFFFA500), // Orange
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header with Plan Name and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(Responsive.padding(context, 10)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: Responsive.iconSize(context, 28),
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, 12)),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Current Plan',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 12),
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          Text(
                            activePlanName,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 22),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'New Driver Special',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 11),
                              color: Colors.white.withOpacity(0.9),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context, 12),
                  vertical: Responsive.padding(context, 6),
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: Responsive.iconSize(context, 14),
                    ),
                    SizedBox(width: Responsive.spacing(context, 4)),
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 12),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.spacing(context, 24)),

          // Earnings Card
          Container(
            padding: EdgeInsets.all(Responsive.padding(context, 20)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
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
                        'Total Earnings',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 13),
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 4)),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatCurrency(totalEarnings),
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 32),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 4)),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.greenAccent,
                            size: Responsive.iconSize(context, 16),
                          ),
                          SizedBox(width: Responsive.spacing(context, 4)),
                          Flexible(
                            child: Text(
                              '100% commission-free',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(context, 12),
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
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

          SizedBox(height: Responsive.spacing(context, 20)),

          // Validity Period
          Row(
            children: [
              Expanded(
                child: Container(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white.withOpacity(0.8),
                            size: Responsive.iconSize(context, 16),
                          ),
                          SizedBox(width: Responsive.spacing(context, 6)),
                          Text(
                            'Validity Period',
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 11),
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.spacing(context, 8)),
                      Text(
                        _formatDate(planStartDate),
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 14),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'to',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 10),
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        _formatDate(planEndDate),
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 14),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 12)),
              Container(
                padding: EdgeInsets.all(Responsive.padding(context, 16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$remainingDays',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 32),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF8C00),
                      ),
                    ),
                    Text(
                      'Days Left',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 11),
                        color: const Color(0xFFFF8C00),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.spacing(context, 16)),

          // Benefits
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context, 4)),
            child: Row(
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.greenAccent,
                  size: Responsive.iconSize(context, 18),
                ),
                SizedBox(width: Responsive.spacing(context, 8)),
                Expanded(
                  child: Text(
                    '0% Commission Active • Keep 100% Earnings',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 12),
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
            ],
          ),
          ),

          // FREE Badge
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(context, 20),
                vertical: Responsive.padding(context, 10),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    size: Responsive.iconSize(context, 18),
                    color: const Color(0xFFFFD700),
                  ),
                  SizedBox(width: Responsive.spacing(context, 6)),
                  Text(
                    'FREE',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment(String planTitle, String planPrice, String planDuration) {
    DateTime startDate = _calculateStartDate();
    DateTime endDate = _calculateEndDate(planTitle);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          planTitle: planTitle,
          planPrice: planPrice,
          planDuration: planDuration,
          validityStartDate: _formatDate(startDate),
          validityEndDate: _formatDate(endDate),
        ),
      ),
    );
  }
}

