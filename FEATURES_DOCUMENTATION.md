# Mobby App - Feature Documentation

## 🏗️ Architecture Pattern
Following **Clean Architecture** with **Riverpod** state management:

```
lib/
├── core/                    # Core utilities, constants, errors
├── features/               # Feature-based organization
│   ├── auth/              # Authentication feature
│   │   ├── data/          # Data layer
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/        # Domain layer
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/  # Presentation layer
│   │       ├── providers/
│   │       ├── screens/
│   │       ├── states/
│   │       └── widgets/
│   └── [other_features]/  # Same structure for each feature
└── main.dart
```

## 📱 CLIENT FEATURES

### 1. Authentication Feature
**Status**: Structure exists, needs implementation
- **Screens**: Login, Register, OTP Verification, Forgot Password
- **Use Cases**: Login, Register, Logout, Verify OTP, Reset Password
- **Entities**: User, AuthToken
- **Data Sources**: Remote Auth API, Local Storage

### 2. Home & Navigation Feature
- **Screens**: Home Dashboard, Search, Bottom Navigation
- **Use Cases**: Get Featured Products, Search Products, Navigate
- **Entities**: Product, Category, Banner
- **Data Sources**: Products API, Search API

### 3. Product Catalog Feature
- **Screens**: Categories, Product List, Product Details, Filters
- **Use Cases**: Browse Categories, Search Products, Get Product Details, Filter Products
- **Entities**: Product, Category, Brand, Review
- **Data Sources**: Products API, Categories API, Reviews API

### 4. Shopping Cart & Checkout Feature
- **Screens**: Cart, Checkout, Payment, Order Confirmation
- **Use Cases**: Add to Cart, Remove from Cart, Checkout, Process Payment
- **Entities**: CartItem, Order, Payment, Address
- **Data Sources**: Cart API, Orders API, Payment Gateway

### 5. Technical Assistance Feature
- **Screens**: Request Form, Chat, Video Call, History
- **Use Cases**: Request Assistance, Chat with Expert, Schedule Call
- **Entities**: AssistanceRequest, Expert, ChatMessage
- **Data Sources**: Support API, Chat API, Video API

### 6. Vehicle Management Feature
- **Screens**: Vehicle List, Add Vehicle, Vehicle Profile, Documents
- **Use Cases**: Register Vehicle, Update Vehicle, Manage Documents
- **Entities**: Vehicle, Document, MaintenanceRecord
- **Data Sources**: Vehicles API, Documents Storage

### 7. LATRA Integration Feature
- **Screens**: LATRA Registration, Status Tracking, Documents
- **Use Cases**: Register with LATRA, Track Status, Upload Documents
- **Entities**: LATRAApplication, LATRAStatus, LATRADocument
- **Data Sources**: LATRA API, Documents API

### 8. Insurance Services Feature
- **Screens**: Insurance Marketplace, Application, Policy Management
- **Use Cases**: Compare Insurance, Apply for Insurance, Manage Policies
- **Entities**: InsuranceProvider, Policy, Claim
- **Data Sources**: Insurance API, Providers API

### 9. Order Management Feature
- **Screens**: Order History, Order Details, Tracking, Returns
- **Use Cases**: View Orders, Track Order, Request Return
- **Entities**: Order, OrderItem, Shipment, Return
- **Data Sources**: Orders API, Tracking API

### 10. User Profile & Settings Feature
- **Screens**: Profile, Settings, Address Book, Payment Methods
- **Use Cases**: Update Profile, Manage Addresses, Manage Payments
- **Entities**: User, Address, PaymentMethod
- **Data Sources**: User API, Addresses API, Payments API

## 🔧 ADMIN FEATURES

### 11. Admin Dashboard Feature
- **Screens**: Dashboard, Analytics, Quick Actions
- **Use Cases**: View Metrics, Generate Reports, Monitor System
- **Entities**: Metric, Report, SystemStatus
- **Data Sources**: Analytics API, Reports API

### 12. Admin Product Management Feature
- **Screens**: Product List, Add/Edit Product, Inventory, Categories
- **Use Cases**: Manage Products, Update Inventory, Manage Categories
- **Entities**: Product, Inventory, Category, Supplier
- **Data Sources**: Products API, Inventory API

### 13. Admin Order Processing Feature
- **Screens**: Order Queue, Order Details, Shipping, Customer Communication
- **Use Cases**: Process Orders, Update Status, Manage Shipping
- **Entities**: Order, OrderStatus, Shipment
- **Data Sources**: Orders API, Shipping API

### 14. Admin Support Management Feature
- **Screens**: Ticket Queue, Expert Management, Performance Metrics
- **Use Cases**: Assign Tickets, Manage Experts, Track Performance
- **Entities**: SupportTicket, Expert, Performance
- **Data Sources**: Support API, Experts API

### 15. Admin LATRA Management Feature
- **Screens**: Application Queue, Document Verification, Integration Status
- **Use Cases**: Process Applications, Verify Documents, Monitor Integration
- **Entities**: LATRAApplication, VerificationStatus
- **Data Sources**: LATRA API, Verification API

### 16. Admin Insurance Management Feature
- **Screens**: Partner Management, Application Processing, Commission Tracking
- **Use Cases**: Manage Partners, Process Applications, Track Commissions
- **Entities**: InsurancePartner, Commission, Application
- **Data Sources**: Insurance API, Partners API

### 17. Notifications & Communication Feature
- **Screens**: Notification Center, Campaign Management, Templates
- **Use Cases**: Send Notifications, Manage Campaigns, Create Templates
- **Entities**: Notification, Campaign, Template
- **Data Sources**: Notifications API, Campaigns API

### 18. Analytics & Reporting Feature
- **Screens**: Analytics Dashboard, Reports, Data Visualization
- **Use Cases**: Generate Reports, Analyze Data, Export Reports
- **Entities**: Report, Metric, Chart
- **Data Sources**: Analytics API, Reports API

## 🧪 Testing Strategy
- **Unit Tests**: For all use cases and business logic
- **Widget Tests**: For all UI components
- **Integration Tests**: For complete user flows
- **Golden Tests**: For UI consistency

## 📦 Core Dependencies
- **State Management**: riverpod
- **HTTP Client**: dio
- **Local Storage**: hive/shared_preferences
- **Navigation**: go_router
- **UI Components**: Custom design system
- **Image Handling**: cached_network_image
- **File Upload**: image_picker
- **Maps**: google_maps_flutter
- **Push Notifications**: firebase_messaging
- **Analytics**: firebase_analytics

## 🚀 Implementation Priority
1. Setup Core App Structure
2. Authentication Feature
3. Home & Navigation Feature
4. Product Catalog Feature
5. Shopping Cart & Checkout Feature
6. Vehicle Management Feature
7. Technical Assistance Feature
8. LATRA Integration Feature
9. Insurance Services Feature
10. Order Management Feature
11. User Profile & Settings Feature
12. Admin Features (12-18)
13. Testing & Quality Assurance

Each feature will be implemented following the same clean architecture pattern as shown in the auth feature structure.
