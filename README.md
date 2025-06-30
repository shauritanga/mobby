# Mobby - Vehicle Parts & Services Mobile Application

Mobby is a specialized Flutter-based mobile application designed to provide a seamless user experience for browsing and purchasing vehicle parts and accessing related services. It focuses on car parts, accessories, and vehicle-related solutions like LATRA and insurance services, with features for user authentication, product catalog browsing, order management, and administrative functionalities.

## Features

- **User Authentication**: A robust system with email/password login, registration, password recovery, email/phone verification with OTP, and secure session management. It features clean architecture for easy database switching and offline support.
- **Vehicle Parts Catalog**: Browse car parts and accessories by categories such as Engine Parts, Tires, Electrical, Fluids, Body Parts, and more.
- **Shopping Cart**: Add vehicle parts to cart and manage quantities before checkout.
- **Order Management**: Place orders for parts and track their status.
- **Admin Dashboard**: Tools for managing inventory, processing orders, and handling other administrative tasks related to vehicle parts and services.
- **Insurance and LATRA Services**: Specialized features for vehicle insurance and LATRA-related government services.
- **Notifications**: Keep users updated with order status, promotions, and service reminders.
- **Responsive Design**: Optimized for various screen sizes and devices.

## Getting Started

To get started with Mobby, follow these steps:

1. **Clone the Repository**: Use `git clone` to get a copy of the project.
2. **Install Dependencies**: Run `flutter pub get` to install the necessary packages.
3. **Run the Application**: Use `flutter run` to start the app on your connected device or emulator.

For more detailed instructions on Flutter development, refer to the [Flutter Documentation](https://docs.flutter.dev/).

## Project Structure

- `lib/core/`: Core utilities, themes, and widgets used across the app.
- `lib/features/`: Feature-specific modules including authentication, cart, home, orders, products, and more.
- `android/` and `ios/`: Platform-specific configurations for Android and iOS.

## Contributing

Contributions to Mobby are welcome. Please feel free to submit a pull request or open an issue for any bugs or feature requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
