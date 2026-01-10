# Demo Data Replacement Guide

## ✅ Completed Updates

### 1. Splash Screen (`lib/driver/home/splash_screen.dart`)
**Changed:**
- ❌ Demo: Always navigate to login after 3 seconds
- ✅ Real: Check authentication status, connect socket if logged in, navigate to home or login

### 2. Home Screen (`lib/driver/home/home_screen.dart`)
**Changed:**
- ❌ Demo: Hardcoded `_isOnDuty` boolean, fake ride requests after 3 seconds
- ✅ Real: Uses `DriverProvider.isOnline` from API
- ✅ Real: Listens to real ride requests via WebSocket
- ✅ Real: Updates location every 10 seconds via API and Socket
- ✅ Real: Toggle duty status calls API
- ⚠️ TODO: Earnings still hardcoded (₹530) - needs earnings API

### 3. Ride Request Screen (`lib/driver/ride/ride_request_screen.dart`)
**Changed:**
- ❌ Demo: Hardcoded pickup/drop addresses passed as strings
- ✅ Real: Accepts `RideModel` with real data from API
- ❌ Demo: Accept just navigates to next screen
- ✅ Real: Calls `rideProvider.acceptRide()` API
- ✅ Real: Shows loading state during API call
- ✅ Real: Handles errors from API

### 4. Ride OTP Screen (`lib/driver/ride/ride_otp_screen.dart`)
**Changed:**
- ❌ Demo: Accepts any 4-digit OTP
- ✅ Real: Verifies OTP against `ride.otp` from API
- ✅ Real: Calls `rideProvider.startRide()` on success
- ✅ Real: Shows actual OTP for testing (from ride model)
- ✅ Real: Clears fields on wrong OTP

---

## 🔴 Screens Still Using Demo Data

### 5. Ride Navigation Screen (`lib/driver/ride/ride_navigation_screen.dart`)
**Needs:**
- Replace hardcoded parameters with `RideModel`
- Call `rideProvider.markArrived()` when at pickup
- Update UI based on real ride status

### 6. Ride Ongoing Screen (`lib/driver/ride/ride_ongoing_screen.dart`)
**Needs:**
- Replace hardcoded parameters with `RideModel`
- Real-time location tracking
- Call `rideProvider.completeRide()` when done
- Show actual customer info from `ride.user`

### 7. Ride Complete Screen (`lib/driver/ride/ride_complete_screen.dart`)
**Needs:**
- Show actual fare from `ride.actualFare`
- Show actual payment method from `ride.paymentMethod`
- Navigate to rate customer with ride ID

### 8. Rate Customer Screen (`lib/driver/ride/rate_customer_screen.dart`)
**Needs:**
- Call `rideProvider.rateCustomer()` API
- Use actual ride ID
- Show success/error feedback

### 9. Earnings Screen (`lib/driver/menu/earnings_screen.dart`)
**Needs:**
- Remove hardcoded earnings data
- Fetch from earnings API
- Show real daily/weekly/monthly earnings
- Real ride count

### 10. Earnings Statement Screen (`lib/driver/earnings/earnings_statement_screen.dart`)
**Needs:**
- Fetch real earnings breakdown
- Real transaction history
- Date-wise earnings from API

### 11. Profile Screen (`lib/driver/menu/profile_screen.dart`)
**Needs:**
- Show data from `AuthProvider.user`
- Show data from `DriverProvider.driver`
- Real profile picture
- Real rating and ride count

### 12. Edit Profile Screen (`lib/driver/menu/edit_profile_screen.dart`)
**Needs:**
- Load data from `AuthProvider.user`
- API call to update profile
- Image upload for profile picture

### 13. Vehicle Screen (`lib/driver/menu/vehicle_screen.dart`)
**Needs:**
- Show data from `DriverProvider.driver`
- Vehicle details from API
- Update vehicle info API

### 14. Ride History Screen (`lib/driver/menu/ride_history_screen.dart`)
**Needs:**
- Remove hardcoded ride list
- Call `rideProvider.getRideHistory()`
- Pagination support
- Show real ride data

### 15. Menu Drawer (`lib/driver/menu/menu_drawer.dart`)
**Needs:**
- Show real driver name from `AuthProvider.user`
- Show real profile picture
- Show real rating
- Call `authProvider.logout()` on logout

---

## 📝 Quick Reference: What to Replace

### Hardcoded Values to Remove:

```dart
// ❌ Remove these patterns:
double _todayEarnings = 530.0;
bool _isOnDuty = false;
String pickupAddress = 'Hotel Grand Sitara';
double fare = 70.0;

// Fake API calls:
Future.delayed(const Duration(seconds: 1), () {
  // Accept any OTP
});

// Hardcoded lists:
final List<Ride> rides = [
  Ride(id: '1', ...),
  Ride(id: '2', ...),
];
```

### Replace With API Patterns:

```dart
// ✅ Use these patterns:

// Provider access
final authProvider = Provider.of<AuthProvider>(context);
final driverProvider = Provider.of<DriverProvider>(context);
final rideProvider = Provider.of<RideProvider>(context);

// API calls
await rideProvider.acceptRide(rideId);
await rideProvider.startRide();
await rideProvider.completeRide();
await rideProvider.cancelRide(reason);

// Loading states
if (provider.isLoading) return CircularProgressIndicator();

// Error handling
if (provider.errorMessage != null) {
  showSnackBar(provider.errorMessage!);
  provider.clearError();
}

// Real data access
final user = authProvider.user;
final driver = driverProvider.driver;
final ride = rideProvider.currentRide;
```

---

## 🎯 Implementation Priority

### High Priority (Core Functionality):
1. ✅ Splash Screen - DONE
2. ✅ Home Screen - DONE
3. ✅ Ride Request Screen - DONE
4. ✅ Ride OTP Screen - DONE
5. ⚠️ Ride Navigation Screen - IN PROGRESS
6. ⚠️ Ride Ongoing Screen - IN PROGRESS
7. ⚠️ Ride Complete Screen - TODO
8. ⚠️ Rate Customer Screen - TODO

### Medium Priority (Driver Info):
9. Profile Screen - TODO
10. Edit Profile Screen - TODO
11. Vehicle Screen - TODO
12. Menu Drawer - TODO

### Lower Priority (Additional Features):
13. Earnings Screen - TODO
14. Earnings Statement - TODO
15. Ride History - TODO

---

## 🔧 Helper Functions for Each Screen

### For Ride Screens:
```dart
// Get current ride
final ride = Provider.of<RideProvider>(context).currentRide;

// Update ride status
await rideProvider.markArrived();
await rideProvider.startRide();
await rideProvider.completeRide();

// Cancel ride
await rideProvider.cancelRide('reason');

// Rate customer
await rideProvider.rateCustomer(rating: 5, review: 'Good');
```

### For Profile Screens:
```dart
// Get user data
final user = Provider.of<AuthProvider>(context).user;
final driver = Provider.of<DriverProvider>(context).driver;

// Display
Text(user?.fullName ?? 'N/A')
Text('${driver?.vehicleModel} - ${driver?.vehicleNumber}')
Text('Rating: ${driver?.rating ?? 0}')
```

### For Earnings Screens:
```dart
// TODO: Create earnings provider and service
// For now, calculate from ride history
final completedRides = rides.where((r) => r.status == 'completed');
final totalEarnings = completedRides.fold(0.0, (sum, r) => sum + (r.actualFare ?? 0));
```

### For History Screens:
```dart
// Load history
await rideProvider.loadRideHistory(page: 1);

// Access history
final rides = rideProvider.rideHistory;

// Pagination
if (hasMore) {
  await rideProvider.loadRideHistory(page: nextPage);
}
```

---

## 📱 Testing Checklist

After replacing demo data, test:

- [ ] Login redirects correctly
- [ ] Home shows real driver status
- [ ] Can toggle online/offline
- [ ] Receive real ride requests
- [ ] Accept ride calls API
- [ ] OTP verification works
- [ ] Ride status updates (arrived, started, completed)
- [ ] Profile shows real data
- [ ] Earnings show real data (when implemented)
- [ ] Ride history loads correctly
- [ ] Logout clears all data

---

## 🚀 Next Steps

1. ✅ Update core ride flow screens (request, OTP) - DONE
2. ⚠️ Update remaining ride screens (navigation, ongoing, complete, rate)
3. Update profile and vehicle screens
4. Implement earnings API and update screens
5. Update ride history screen
6. Update menu drawer
7. Test complete flow end-to-end
8. Remove all console logs and debug code

---

This document tracks the migration from demo/hardcoded data to real API integration.
