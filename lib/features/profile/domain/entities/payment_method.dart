import 'package:equatable/equatable.dart';

/// Payment method entity for user payment methods
/// Following the specifications from FEATURES_DOCUMENTATION.md
class PaymentMethod extends Equatable {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String displayName;
  final String? cardNumber; // Last 4 digits for cards
  final String? cardHolderName;
  final String? expiryMonth;
  final String? expiryYear;
  final String? bankName;
  final String? accountNumber; // Last 4 digits for bank accounts
  final String? mobileNumber; // For mobile money
  final String? provider; // M-Pesa, Tigo Pesa, Airtel Money, etc.
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.displayName,
    this.cardNumber,
    this.cardHolderName,
    this.expiryMonth,
    this.expiryYear,
    this.bankName,
    this.accountNumber,
    this.mobileNumber,
    this.provider,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  PaymentMethod copyWith({
    String? id,
    String? userId,
    PaymentMethodType? type,
    String? displayName,
    String? cardNumber,
    String? cardHolderName,
    String? expiryMonth,
    String? expiryYear,
    String? bankName,
    String? accountNumber,
    String? mobileNumber,
    String? provider,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      provider: provider ?? this.provider,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get masked display text for security
  String get maskedDisplayText {
    switch (type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return '**** **** **** ${cardNumber ?? '****'}';
      case PaymentMethodType.bankAccount:
        return '${bankName ?? 'Bank'} ****${accountNumber ?? '****'}';
      case PaymentMethodType.mobileMoney:
        return '${provider ?? 'Mobile Money'} ${mobileNumber ?? ''}';
      case PaymentMethodType.cashOnDelivery:
        return 'Cash on Delivery';
    }
  }

  /// Check if payment method is expired (for cards)
  bool get isExpired {
    if (type != PaymentMethodType.creditCard && type != PaymentMethodType.debitCard) {
      return false;
    }
    
    if (expiryMonth == null || expiryYear == null) return false;
    
    final now = DateTime.now();
    final expiry = DateTime(
      int.parse('20$expiryYear'),
      int.parse(expiryMonth!),
    );
    
    return now.isAfter(expiry);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        displayName,
        cardNumber,
        cardHolderName,
        expiryMonth,
        expiryYear,
        bankName,
        accountNumber,
        mobileNumber,
        provider,
        isDefault,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Payment method types for Tanzania market
enum PaymentMethodType {
  creditCard('Credit Card'),
  debitCard('Debit Card'),
  bankAccount('Bank Account'),
  mobileMoney('Mobile Money'),
  cashOnDelivery('Cash on Delivery');

  const PaymentMethodType(this.displayName);
  final String displayName;
}

/// Popular mobile money providers in Tanzania
enum MobileMoneyProvider {
  mpesa('M-Pesa'),
  tigoPesa('Tigo Pesa'),
  airtelMoney('Airtel Money'),
  halopesa('HaloPesa'),
  ttcl('TTCL Mobile');

  const MobileMoneyProvider(this.displayName);
  final String displayName;
}
