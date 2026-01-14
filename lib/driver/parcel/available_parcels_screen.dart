import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/providers/parcel_provider.dart';
import 'parcel_job_screen.dart';

class AvailableParcelsScreen extends StatefulWidget {
  const AvailableParcelsScreen({super.key});

  @override
  State<AvailableParcelsScreen> createState() => _AvailableParcelsScreenState();
}

class _AvailableParcelsScreenState extends State<AvailableParcelsScreen> {
  final AppTheme _appTheme = AppTheme();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      await context.read<ParcelProvider>().refreshAvailable(
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location error: $e'),
          backgroundColor: _appTheme.brandRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParcelProvider>();
    final parcels = provider.availableParcels;

    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Available Parcels'),
          backgroundColor: Colors.white,
          foregroundColor: _appTheme.textColor,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: EdgeInsets.all(Responsive.padding(context, 16)),
            children: [
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: _appTheme.brandRed),
                  ),
                ),
              if (provider.isLoading && parcels.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (parcels.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No parcel jobs right now.\nPull to refresh.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _appTheme.textGrey),
                    ),
                  ),
                )
              else
                ...parcels.map((p) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.trackingNumber.isNotEmpty ? p.trackingNumber : p.id,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.w700,
                              color: _appTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Pickup: ${p.pickupAddress}', maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('Drop: ${p.dropoffAddress}', maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Text('Fare: ₹${p.fare.toStringAsFixed(0)}'),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: provider.isLoading
                                  ? null
                                  : () async {
                                      final ok = await context.read<ParcelProvider>().accept(p.id);
                                      if (!mounted) return;
                                      if (ok) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (_) => const ParcelJobScreen()),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(provider.errorMessage ?? 'Accept failed'),
                                            backgroundColor: _appTheme.brandRed,
                                          ),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(backgroundColor: _appTheme.brandRed),
                              child: const Text('Accept Parcel'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

