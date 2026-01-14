import 'package:flutter/material.dart';
import '../../core/services/subscription_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final AppTheme _appTheme = AppTheme();
  final SubscriptionService _subscriptionService = SubscriptionService();

  bool _loading = true;
  bool _mutating = false;
  String? _error;
  Map<String, dynamic>? _ui;

  String _paymentMethod = 'wallet';

  @override
  void initState() {
    super.initState();
    _appTheme.addListener(_onThemeChanged);
    _loadUi();
  }

  @override
  void dispose() {
    _appTheme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  Future<void> _loadUi() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await _subscriptionService.getUi();
    if (!mounted) return;

    if (res.isSuccess && res.data != null) {
      setState(() {
        _ui = res.data;
        _loading = false;
      });
    } else {
      setState(() {
        _error = res.message ?? 'Failed to load subscriptions';
        _loading = false;
      });
    }
  }

  Future<void> _subscribeToPlan(Map<String, dynamic> plan) async {
    if (_mutating) return;
    final planId = plan['id']?.toString();
    final planCode = plan['code']?.toString();
    if ((planId == null || planId.isEmpty) && (planCode == null || planCode.isEmpty)) {
      _showError('Invalid plan');
      return;
    }

    setState(() => _mutating = true);
    final res = await _subscriptionService.subscribe(
      planId: planId,
      planCode: planCode,
      paymentMethod: _paymentMethod,
    );
    if (!mounted) return;
    setState(() => _mutating = false);

    if (res.isSuccess) {
      _showSuccess('Subscribed successfully');
      await _loadUi();
    } else {
      _showError(res.message ?? 'Failed to subscribe');
    }
  }

  Future<void> _cancelSubscription() async {
    if (_mutating) return;
    setState(() => _mutating = true);
    final res = await _subscriptionService.cancel();
    if (!mounted) return;
    setState(() => _mutating = false);

    if (res.isSuccess) {
      _showSuccess('Subscription cancelled');
      await _loadUi();
    } else {
      _showError(res.message ?? 'Failed to cancel');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _appTheme.brandRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _ui?['data'] is Map<String, dynamic> ? (_ui!['data'] as Map<String, dynamic>) : _ui;
    final bool hasActive = (data?['hasActivePlan'] == true) && (data?['activePlan'] != null);
    final Map<String, dynamic>? activePlan = hasActive ? (data?['activePlan'] as Map<String, dynamic>?) : null;

    final plansRaw = (data?['plans'] is List) ? (data?['plans'] as List) : const [];
    final plans = plansRaw.whereType<Map<String, dynamic>>().toList(growable: false);

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
          onPressed: () => Navigator.pop(context, true),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.padding(context, 20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        SizedBox(height: Responsive.spacing(context, 12)),
                        ElevatedButton(onPressed: _loadUi, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUi,
                  child: ListView(
                    padding: EdgeInsets.all(Responsive.padding(context, 16)),
                    children: [
                      if (hasActive && activePlan != null) ...[
                        _buildActivePlan(activePlan),
                        SizedBox(height: Responsive.spacing(context, 16)),
                      ],
                      _buildPaymentMethodPicker(),
                      SizedBox(height: Responsive.spacing(context, 12)),
                      Text(
                        'Plans',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: _appTheme.textColor,
                        ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 12)),
                      if (plans.isEmpty)
                        Text('No active plans found.', style: TextStyle(color: _appTheme.textGrey))
                      else
                        ...plans.map(_buildPlanCard),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPaymentMethodPicker() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context, 12),
        vertical: Responsive.padding(context, 10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, color: _appTheme.textGrey),
          SizedBox(width: Responsive.spacing(context, 10)),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _paymentMethod,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'wallet', child: Text('Wallet')),
                  DropdownMenuItem(value: 'upi', child: Text('UPI')),
                  DropdownMenuItem(value: 'card', child: Text('Card')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                ],
                onChanged: _mutating
                    ? null
                    : (v) {
                        if (v == null) return;
                        setState(() => _paymentMethod = v);
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlan(Map<String, dynamic> activePlan) {
    return Container(
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.green),
              SizedBox(width: Responsive.spacing(context, 8)),
              Expanded(
                child: Text(
                  'Active Plan',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: _appTheme.textColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: _mutating ? null : _cancelSubscription,
                child: Text(_mutating ? '...' : 'Cancel'),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 8)),
          Text(
            (activePlan['name'] ?? '—').toString(),
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: _appTheme.textColor,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 6)),
          Text('Valid until: ${(activePlan['endDate'] ?? '').toString()}',
              style: TextStyle(color: _appTheme.textGrey)),
          if (activePlan['remainingDays'] != null) ...[
            SizedBox(height: Responsive.spacing(context, 6)),
            Text('Remaining days: ${activePlan['remainingDays']}',
                style: TextStyle(color: _appTheme.textGrey)),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final title = (plan['title'] ?? plan['name'] ?? '').toString();
    final price = (plan['priceDisplay'] ?? plan['price'] ?? '').toString();
    final duration = (plan['durationLabel'] ?? plan['duration'] ?? '').toString();
    final features = plan['features'] is List ? (plan['features'] as List) : const [];
    final recommended = plan['isRecommended'] == true;
    final bestValue = plan['isBestValue'] == true;

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
      padding: EdgeInsets.all(Responsive.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: recommended
              ? Colors.blue.shade200
              : bestValue
                  ? Colors.orange.shade200
                  : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: _appTheme.textColor,
                  ),
                ),
              ),
              if (recommended) _badge('Recommended', Colors.blue),
              if (!recommended && bestValue) _badge('Best value', Colors.orange),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 6)),
          Text('$price • $duration', style: TextStyle(color: _appTheme.textGrey)),
          if (features.isNotEmpty) ...[
            SizedBox(height: Responsive.spacing(context, 10)),
            ...features.take(4).map((f) => Padding(
                  padding: EdgeInsets.only(bottom: Responsive.spacing(context, 6)),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 18, color: Colors.green),
                      SizedBox(width: Responsive.spacing(context, 8)),
                      Expanded(child: Text(f.toString())),
                    ],
                  ),
                )),
          ],
          SizedBox(height: Responsive.spacing(context, 10)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _mutating ? null : () => _subscribeToPlan(plan),
              child: Text(_mutating ? 'Please wait…' : 'Subscribe'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, MaterialColor color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.padding(context, 10),
        vertical: Responsive.padding(context, 4),
      ),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: Responsive.fontSize(context, 12),
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }
}

