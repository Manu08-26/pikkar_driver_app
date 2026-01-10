# Pikkar Driver App - Testing Checklist

Use this checklist to verify all API integrations are working correctly.

---

## 📋 Pre-Testing Setup

- [ ] Backend server is running
- [ ] Updated `ApiConstants.baseUrl` with correct URL
- [ ] Updated `ApiConstants.socketUrl` with correct URL
- [ ] Run `flutter pub get`
- [ ] Have test credentials ready (email/password)

---

## 🔐 Authentication Tests

### Login
- [ ] Open app → navigates to login screen
- [ ] Enter valid email and password
- [ ] Click "Login" button
- [ ] Loading indicator shows
- [ ] Login succeeds → navigates to home screen
- [ ] Token is saved (check by restarting app)

### Invalid Login
- [ ] Enter invalid email/password
- [ ] Click "Login" button
- [ ] Error message displays
- [ ] Stays on login screen

### Token Persistence
- [ ] Login successfully
- [ ] Close and restart app
- [ ] App should stay logged in (skip login screen)

### Logout
- [ ] Click logout from menu
- [ ] Redirected to login screen
- [ ] Token is cleared
- [ ] Restart app → goes to login screen

---

## 👤 Driver Profile Tests

### Driver Registration
- [ ] Register as new driver
- [ ] Enter all vehicle details
- [ ] Submit registration
- [ ] Success message displays
- [ ] Driver profile is saved

### View Profile
- [ ] Open profile screen
- [ ] All user details display correctly
- [ ] Driver details display correctly
- [ ] Vehicle information shows

---

## 🚗 Driver Status Tests

### Toggle Online Status
- [ ] Driver starts offline
- [ ] Toggle switch to online
- [ ] Status updates in UI
- [ ] Backend receives status update
- [ ] Toggle back to offline
- [ ] Status updates again

### Location Updates
- [ ] Driver goes online
- [ ] Grant location permissions
- [ ] Location updates every 10 seconds
- [ ] Check backend receives location
- [ ] Check socket broadcasts location
- [ ] Map shows current location

---

## 🔌 WebSocket Tests

### Connection
- [ ] Login to app
- [ ] Socket connects automatically
- [ ] Connection status indicator shows "Connected"
- [ ] Check socket authentication token

### Disconnection
- [ ] Turn off WiFi/data
- [ ] Connection status shows "Disconnected"
- [ ] Turn on WiFi/data
- [ ] Socket reconnects automatically
- [ ] Connection status shows "Connected"

### Event Listening
- [ ] Socket is connected
- [ ] Send test ride request from backend
- [ ] App receives ride request event
- [ ] UI shows ride request notification/dialog

---

## 🚖 Ride Management Tests

### Receive Ride Request
- [ ] Driver is online
- [ ] Backend sends ride request
- [ ] App receives notification
- [ ] Ride details display correctly:
  - [ ] Pickup address
  - [ ] Drop address
  - [ ] Distance
  - [ ] Estimated fare
  - [ ] Customer details

### Accept Ride
- [ ] Receive ride request
- [ ] Click "Accept" button
- [ ] Loading indicator shows
- [ ] Ride accepted successfully
- [ ] Navigate to ride detail screen
- [ ] Backend receives acceptance
- [ ] Socket broadcasts to customer

### Reject Ride
- [ ] Receive ride request
- [ ] Click "Reject" button
- [ ] Dialog closes
- [ ] Request removed from pending
- [ ] Still available for new requests

### Mark Arrived
- [ ] Accept a ride
- [ ] Navigate to pickup location
- [ ] Click "Mark Arrived" button
- [ ] Status updates to "arrived"
- [ ] Customer notified via socket
- [ ] UI updates accordingly

### Start Ride (Enter OTP)
- [ ] Driver at pickup location
- [ ] Status is "arrived"
- [ ] Enter OTP from customer
- [ ] OTP validated
- [ ] Ride status updates to "started"
- [ ] Navigation to destination starts
- [ ] Customer notified

### Complete Ride
- [ ] Reach destination
- [ ] Click "Complete Ride" button
- [ ] Ride status updates to "completed"
- [ ] Fare calculation shows
- [ ] Customer notified
- [ ] Navigate to rating screen

### Cancel Ride
- [ ] Have active ride
- [ ] Click "Cancel" button
- [ ] Enter cancellation reason
- [ ] Confirm cancellation
- [ ] Ride cancelled
- [ ] Customer notified
- [ ] Return to home screen

### Rate Customer
- [ ] Complete a ride
- [ ] Rating screen appears
- [ ] Select star rating (1-5)
- [ ] Optionally add review
- [ ] Submit rating
- [ ] Rating saved successfully

---

## 📊 Ride History Tests

### View History
- [ ] Open ride history screen
- [ ] List of completed rides displays
- [ ] Each ride shows:
  - [ ] Pickup address
  - [ ] Drop address
  - [ ] Fare amount
  - [ ] Date/time
  - [ ] Rating

### Pagination
- [ ] Scroll to bottom of list
- [ ] Next page loads automatically
- [ ] No duplicate rides
- [ ] Loading indicator shows while loading

### Filter by Status
- [ ] Filter by "Completed"
- [ ] Only completed rides show
- [ ] Filter by "Cancelled"
- [ ] Only cancelled rides show

---

## 💰 Earnings Tests

### View Earnings
- [ ] Open earnings screen
- [ ] Today's earnings display
- [ ] Weekly earnings display
- [ ] Monthly earnings display
- [ ] Total rides count

### Earnings Breakdown
- [ ] View earnings by date range
- [ ] Details match ride history
- [ ] Calculations are correct

---

## 🔔 Notification Tests

### Ride Request Notification
- [ ] App in background
- [ ] Receive ride request
- [ ] Push notification shows
- [ ] Tap notification → opens ride request

### Ride Status Notifications
- [ ] Customer cancels ride
- [ ] Notification received
- [ ] Payment received notification
- [ ] Rating received notification

---

## 📶 Network Tests

### No Internet Connection
- [ ] Turn off WiFi and mobile data
- [ ] Try to login
- [ ] Error message: "No internet connection"
- [ ] Try to accept ride
- [ ] Error message displays

### Slow Connection
- [ ] Use slow network (3G)
- [ ] All requests work (with delay)
- [ ] Loading indicators show
- [ ] Timeout handled gracefully

### Connection Recovery
- [ ] Lose connection during ride
- [ ] Turn connection back on
- [ ] Socket reconnects
- [ ] State syncs with backend
- [ ] No data loss

---

## 🔄 State Management Tests

### Provider Updates
- [ ] Login → AuthProvider updates
- [ ] UI rebuilds with user data
- [ ] Toggle status → DriverProvider updates
- [ ] UI rebuilds with new status
- [ ] Accept ride → RideProvider updates
- [ ] UI rebuilds with ride data

### Error Handling
- [ ] API call fails
- [ ] Error message in provider
- [ ] UI displays error
- [ ] User can retry
- [ ] Error clears after success

### Loading States
- [ ] Start async operation
- [ ] Loading indicator shows
- [ ] Operation completes
- [ ] Loading indicator hides
- [ ] Data displays

---

## 🔐 Security Tests

### Token Storage
- [ ] Login successfully
- [ ] Close app completely
- [ ] Check secure storage has token
- [ ] Reopen app → still logged in
- [ ] Logout
- [ ] Check secure storage is cleared

### Token Refresh
- [ ] Wait for token to expire (or manually expire)
- [ ] Make API call
- [ ] Token refreshed automatically
- [ ] Original request succeeds
- [ ] No error shown to user

### Unauthorized Access
- [ ] Manually clear token
- [ ] Try to access protected route
- [ ] Redirected to login
- [ ] Login required message shows

---

## 🎨 UI/UX Tests

### Login Screen
- [ ] Logo displays correctly
- [ ] Email input works
- [ ] Password input works
- [ ] Show/hide password works
- [ ] Loading state during login
- [ ] Error messages display nicely

### Home Screen
- [ ] Map loads correctly
- [ ] Current location shows
- [ ] Online/offline toggle works
- [ ] Today's earnings display
- [ ] Menu drawer opens

### Ride Request Screen
- [ ] All ride details visible
- [ ] Accept button enabled
- [ ] Reject button enabled
- [ ] Countdown timer (if any)
- [ ] Animation smooth

### Ride Detail Screen
- [ ] Pickup location on map
- [ ] Drop location on map
- [ ] Route drawn on map
- [ ] Customer details visible
- [ ] Action buttons visible

---

## 📱 Device Tests

### Android
- [ ] Test on Android emulator
- [ ] Test on physical Android device
- [ ] Location permissions work
- [ ] Push notifications work
- [ ] Background mode works

### iOS (if applicable)
- [ ] Test on iOS simulator
- [ ] Test on physical iOS device
- [ ] Location permissions work
- [ ] Push notifications work
- [ ] Background mode works

---

## 🐛 Edge Cases

### Multiple Ride Requests
- [ ] Receive multiple ride requests
- [ ] Can view all pending requests
- [ ] Accept one, others disappear
- [ ] Only one active ride at a time

### Rapid Status Changes
- [ ] Accept ride
- [ ] Immediately mark arrived
- [ ] Immediately start ride
- [ ] All updates process correctly
- [ ] No race conditions

### App Background/Foreground
- [ ] Accept ride
- [ ] Put app in background
- [ ] Customer cancels
- [ ] Bring app to foreground
- [ ] State synced correctly

### App Kill/Restart
- [ ] Have active ride
- [ ] Kill app
- [ ] Restart app
- [ ] Active ride still shows
- [ ] Can continue from where left off

---

## ✅ Final Verification

- [ ] All authentication flows work
- [ ] All driver operations work
- [ ] All ride operations work
- [ ] WebSocket events work
- [ ] Error handling works
- [ ] Loading states work
- [ ] Network recovery works
- [ ] Token management works
- [ ] No crashes or errors
- [ ] Performance is acceptable

---

## 📝 Notes

**Issues Found:**
```
1. 
2. 
3. 
```

**Improvements Needed:**
```
1. 
2. 
3. 
```

**Test Date:** _______________

**Tested By:** _______________

**Backend Version:** _______________

**App Version:** _______________

---

## 🎯 Success Criteria

For production readiness, ensure:

✅ All authentication tests pass  
✅ All ride management tests pass  
✅ WebSocket connection is stable  
✅ No data loss scenarios  
✅ Graceful error handling  
✅ Good user experience  
✅ No security vulnerabilities  
✅ Performance is acceptable  

---

**Happy Testing! 🚀**
