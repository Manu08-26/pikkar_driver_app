import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/parcel_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class ParcelJobScreen extends StatefulWidget {
  const ParcelJobScreen({super.key});

  @override
  State<ParcelJobScreen> createState() => _ParcelJobScreenState();
}

class _ParcelJobScreenState extends State<ParcelJobScreen> {
  final AppTheme _appTheme = AppTheme();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParcelProvider>();
    final parcel = provider.activeParcel;

    if (parcel == null) {
      return Directionality(
        textDirection: _appTheme.textDirection,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Parcel Job'),
            backgroundColor: Colors.white,
            foregroundColor: _appTheme.textColor,
            elevation: 0,
          ),
          backgroundColor: Colors.white,
          body: Center(
            child: Text('No active parcel job', style: TextStyle(color: _appTheme.textGrey)),
          ),
        ),
      );
    }

    final status = parcel.status;
    // Rough heuristic to switch from pickup OTP → delivery OTP
    final isPickupOtp = status != 'picked_up' && status != 'in_transit';

    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Parcel Job'),
          backgroundColor: Colors.white,
          foregroundColor: _appTheme.textColor,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(Responsive.padding(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parcel.trackingNumber.isNotEmpty ? parcel.trackingNumber : parcel.id,
                style: TextStyle(fontSize: Responsive.fontSize(context, 18), fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('Status: ${parcel.status}'),
              const SizedBox(height: 16),
              Text('Pickup: ${parcel.pickupAddress}'),
              const SizedBox(height: 8),
              Text('Drop: ${parcel.dropoffAddress}'),
              const SizedBox(height: 24),
              Text(
                isPickupOtp ? 'Enter Pickup OTP' : 'Enter Delivery OTP',
                style: TextStyle(fontSize: Responsive.fontSize(context, 16), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '6-digit OTP',
                ),
              ),
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(provider.errorMessage!, style: TextStyle(color: _appTheme.brandRed)),
              ],
              if (status == 'picked_up') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            final ok = await context.read<ParcelProvider>().markInTransit();
                            if (!mounted) return;
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.errorMessage ?? 'Failed to update'),
                                  backgroundColor: _appTheme.brandRed,
                                ),
                              );
                            }
                          },
                    child: const Text('Mark In Transit'),
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          final otp = _otpController.text.trim();
                          if (otp.length < 4) return;
                          final ok = isPickupOtp
                              ? await context.read<ParcelProvider>().pickup(otp: otp)
                              : await context.read<ParcelProvider>().deliver(otp: otp);
                          if (!mounted) return;
                          if (ok) {
                            _otpController.clear();
                            if (!isPickupOtp) {
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pickup confirmed')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.errorMessage ?? 'OTP verification failed'),
                                backgroundColor: _appTheme.brandRed,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: _appTheme.brandRed),
                  child: Text(isPickupOtp ? 'Confirm Pickup' : 'Confirm Delivery'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

