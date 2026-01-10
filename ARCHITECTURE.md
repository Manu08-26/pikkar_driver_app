# Pikkar Driver App - Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          UI LAYER (Screens)                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │ Login Screen │  │ Home Screen  │  │ Ride Screen  │  ...       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘            │
│         │                  │                  │                     │
│         │     Uses Provider Pattern (Consumer/Provider.of)         │
│         │                  │                  │                     │
└─────────┼──────────────────┼──────────────────┼─────────────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    PROVIDER LAYER (State Management)                │
│  ┌───────────────┐  ┌────────────────┐  ┌──────────────┐         │
│  │ AuthProvider  │  │ DriverProvider │  │ RideProvider │         │
│  │               │  │                │  │              │         │
│  │ - user        │  │ - driver       │  │ - currentRide│         │
│  │ - isLoading   │  │ - isOnline     │  │ - history    │         │
│  │ - error       │  │ - error        │  │ - pending    │         │
│  └───────┬───────┘  └────────┬───────┘  └──────┬───────┘         │
└──────────┼────────────────────┼──────────────────┼─────────────────┘
           │                    │                  │
           │    Calls Service Methods              │
           │                    │                  │
           ▼                    ▼                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      SERVICE LAYER (Business Logic)                 │
│  ┌───────────────┐  ┌────────────────┐  ┌──────────────┐         │
│  │ AuthService   │  │ DriverService  │  │ RideService  │         │
│  │               │  │                │  │              │         │
│  │ - login()     │  │ - toggleOnline │  │ - acceptRide │         │
│  │ - logout()    │  │ - updateLoc()  │  │ - startRide  │         │
│  │ - register()  │  │ - register()   │  │ - complete() │         │
│  └───────┬───────┘  └────────┬───────┘  └──────┬───────┘         │
└──────────┼────────────────────┼──────────────────┼─────────────────┘
           │                    │                  │
           │    Uses API Client & Socket Service   │
           │                    │                  │
           ▼                    ▼                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    NETWORK LAYER (HTTP & WebSocket)                 │
│  ┌───────────────────────────────────┐  ┌─────────────────────┐   │
│  │        ApiClient (Dio)            │  │  SocketService      │   │
│  │                                   │  │                     │   │
│  │ - Automatic token injection       │  │ - Real-time events  │   │
│  │ - Auto token refresh              │  │ - Auto reconnect    │   │
│  │ - Error handling                  │  │ - Event streams     │   │
│  │ - Request/Response interceptors   │  │ - Status monitor    │   │
│  └───────────────┬───────────────────┘  └──────────┬──────────┘   │
└──────────────────┼──────────────────────────────────┼──────────────┘
                   │                                  │
                   │                                  │
                   ▼                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   BACKEND SERVER (Pikkar API)                       │
│                                                                     │
│  REST API (HTTP)                    WebSocket                       │
│  ┌─────────────────────┐           ┌──────────────────┐           │
│  │ /auth/*             │           │ ride:new         │           │
│  │ /drivers/*          │           │ ride:accepted    │           │
│  │ /rides/*            │           │ ride:status      │           │
│  └─────────────────────┘           └──────────────────┘           │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Authentication Flow
```
LoginScreen
    │
    ├─► AuthProvider.login(email, password)
    │       │
    │       ├─► AuthService.login()
    │       │       │
    │       │       ├─► ApiClient.post('/auth/login')
    │       │       │       │
    │       │       │       ├─► Backend API
    │       │       │       │
    │       │       │       └─► Response (user + tokens)
    │       │       │
    │       │       └─► TokenStorage.saveTokens()
    │       │       └─► TokenStorage.saveUser()
    │       │
    │       └─► notifyListeners() → UI updates
    │
    └─► SocketService.connect()
    └─► Navigate to Home
```

### Ride Request Flow
```
Backend sends ride request
    │
    └─► Socket.emit('ride:new', rideData)
            │
            └─► SocketService.onRideRequest
                    │
                    └─► RideProvider (adds to pendingRides)
                            │
                            └─► UI shows notification/dialog
                                    │
                                    └─► Driver accepts
                                            │
                                            └─► RideProvider.acceptRide(id)
                                                    │
                                                    └─► RideService.acceptRide()
                                                            │
                                                            └─► ApiClient.put('/rides/:id/accept')
                                                                    │
                                                                    └─► Backend API
                                                                            │
                                                                            └─► Update ride status
                                                                                    │
                                                                                    └─► Socket broadcasts update
```

### Location Update Flow
```
Timer (every 10s)
    │
    └─► Get GPS location
            │
            ├─► DriverProvider.updateLocation(lng, lat)
            │       │
            │       └─► DriverService.updateLocation()
            │               │
            │               └─► ApiClient.put('/drivers/location')
            │                       │
            │                       └─► Backend saves location
            │
            └─► SocketService.updateDriverLocation(lng, lat)
                    │
                    └─► Socket.emit('driver:location')
                            │
                            └─► Backend broadcasts to riders
```

## Component Relationships

```
┌──────────────────────────────────────────────────────────────┐
│                        APP ROOT                              │
│                     MultiProvider                            │
│  ┌────────────────────────────────────────────────────┐    │
│  │  ChangeNotifierProvider(AuthProvider)              │    │
│  │  ChangeNotifierProvider(DriverProvider)            │    │
│  │  ChangeNotifierProvider(RideProvider)              │    │
│  └────────────────────────────────────────────────────┘    │
│                          │                                   │
│                          ▼                                   │
│                   MaterialApp                                │
│                     Routes                                   │
└──────────────────────────────────────────────────────────────┘

Each Provider has:
┌─────────────────────────────────────┐
│         Provider                    │
│  ┌──────────────────────────────┐  │
│  │ State Variables              │  │
│  │ - data                       │  │
│  │ - isLoading                  │  │
│  │ - errorMessage               │  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │ Service Instance             │  │
│  │ - authService / driverService│  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │ Methods                      │  │
│  │ - async operations           │  │
│  │ - notifyListeners()          │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

## State Update Cycle

```
User Action
    │
    ▼
Widget calls Provider method
    │
    ▼
Provider sets isLoading = true
    │
    ▼
Provider calls Service
    │
    ▼
Service calls ApiClient
    │
    ▼
ApiClient makes HTTP request
    │
    ▼
Backend processes & responds
    │
    ▼
ApiClient parses response
    │
    ▼
Service returns result
    │
    ▼
Provider updates state
    │
    ├─► Success: update data, clear error
    └─► Error: set errorMessage
    │
    ▼
Provider sets isLoading = false
    │
    ▼
Provider calls notifyListeners()
    │
    ▼
All listening widgets rebuild
    │
    ▼
UI shows updated state
```

## Model Hierarchy

```
┌─────────────────────────────────────────────────────────┐
│                    ApiResponse<T>                       │
│  ┌───────────────────────────────────────────────┐    │
│  │ status: String                                 │    │
│  │ message: String?                               │    │
│  │ data: T?                                       │    │
│  │ results: int?                                  │    │
│  │ pagination: PaginationData?                    │    │
│  └───────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                        │
                        ├─► UserModel
                        ├─► DriverModel
                        ├─► RideModel
                        ├─► List<RideModel>
                        └─► Map<String, dynamic>

┌─────────────────────────────────────────────────────────┐
│                      UserModel                          │
│  id, firstName, lastName, email, phone, role,          │
│  rating, totalRides, profilePicture                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    DriverModel                          │
│  id, userId, user, licenseNumber, vehicleType,         │
│  vehicleModel, vehicleNumber, currentLocation,         │
│  isOnline, isAvailable, rating, verificationStatus     │
│  ┌─────────────────────────────────────────────┐      │
│  │ LocationCoordinates                         │      │
│  │   type, coordinates [lng, lat]              │      │
│  └─────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                     RideModel                           │
│  id, userId, driverId, pickupLocation,                 │
│  dropoffLocation, vehicleType, status,                 │
│  estimatedFare, actualFare, distance, otp,             │
│  paymentMethod, rating, review                         │
│  ┌─────────────────────────────────────────────┐      │
│  │ RideLocation                                │      │
│  │   coordinates [lng, lat], address           │      │
│  └─────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘
```

## Error Handling Flow

```
API Call
    │
    ├─► Success (200, 201)
    │       │
    │       └─► Parse response
    │               │
    │               └─► Return ApiResponse(success)
    │
    └─► Error
            │
            ├─► Network Error (No connection)
            │       └─► Return "No internet connection"
            │
            ├─► Timeout Error
            │       └─► Return "Connection timeout"
            │
            ├─► 401 Unauthorized
            │       │
            │       └─► Try refresh token
            │               │
            │               ├─► Success → Retry original request
            │               └─► Fail → Clear tokens → Redirect to login
            │
            ├─► 400, 403, 404, 500...
            │       └─► Parse error message from response
            │               └─► Return ApiResponse(fail)
            │
            └─► Unknown Error
                    └─► Return "An error occurred"
```

This architecture provides:
- ✅ Separation of concerns
- ✅ Testability
- ✅ Maintainability
- ✅ Scalability
- ✅ Type safety
- ✅ Reactive UI updates
- ✅ Centralized state management
- ✅ Automatic error handling
