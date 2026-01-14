import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/parcel_provider.dart';
import '../../core/services/parcel_service.dart';
import '../../core/models/parcel_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class ParcelHistoryScreen extends StatefulWidget {
  const ParcelHistoryScreen({super.key});

  @override
  State<ParcelHistoryScreen> createState() => _ParcelHistoryScreenState();
}

class _ParcelHistoryScreenState extends State<ParcelHistoryScreen> {
  final AppTheme _appTheme = AppTheme();
  final ParcelService _service = ParcelService();
  bool _loading = false;
  String? _error;
  List<ParcelModel> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _service.getMyParcels(page: 1, limit: 50);
    setState(() {
      _loading = false;
      if (res.isSuccess && res.data != null) {
        _items = res.data!;
      } else {
        _error = res.message ?? 'Failed to load parcels';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = context.watch<ParcelProvider>().activeParcel;
    return Directionality(
      textDirection: _appTheme.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Parcel History'),
          backgroundColor: Colors.white,
          foregroundColor: _appTheme.textColor,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: EdgeInsets.all(Responsive.padding(context, 16)),
            children: [
              if (active != null)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active Parcel', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(active.trackingNumber.isNotEmpty ? active.trackingNumber : active.id),
                        const SizedBox(height: 4),
                        Text('Status: ${active.status}'),
                      ],
                    ),
                  ),
                ),
              if (_loading) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: TextStyle(color: _appTheme.brandRed))),
              ..._items.map((p) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.trackingNumber.isNotEmpty ? p.trackingNumber : p.id, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('Status: ${p.status}'),
                        const SizedBox(height: 6),
                        Text('Pickup: ${p.pickupAddress}', maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Drop: ${p.dropoffAddress}', maxLines: 1, overflow: TextOverflow.ellipsis),
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

