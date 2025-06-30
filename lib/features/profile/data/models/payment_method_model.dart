import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment_method.dart';

part 'payment_method_model.g.dart';

/// Payment method model for data layer
/// Following Firebase integration pattern as specified in FEATURES_DOCUMENTATION.md
@JsonSerializable()
class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.displayName,
    super.cardNumber,
    super.cardHolderName,
    super.expiryMonth,
    super.expiryYear,
    super.bankName,
    super.accountNumber,
    super.mobileNumber,
    super.provider,
    super.isDefault,
    super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodModelToJson(this);

  factory PaymentMethodModel.fromEntity(PaymentMethod paymentMethod) {
    return PaymentMethodModel(
      id: paymentMethod.id,
      userId: paymentMethod.userId,
      type: paymentMethod.type,
      displayName: paymentMethod.displayName,
      cardNumber: paymentMethod.cardNumber,
      cardHolderName: paymentMethod.cardHolderName,
      expiryMonth: paymentMethod.expiryMonth,
      expiryYear: paymentMethod.expiryYear,
      bankName: paymentMethod.bankName,
      accountNumber: paymentMethod.accountNumber,
      mobileNumber: paymentMethod.mobileNumber,
      provider: paymentMethod.provider,
      isDefault: paymentMethod.isDefault,
      isActive: paymentMethod.isActive,
      createdAt: paymentMethod.createdAt,
      updatedAt: paymentMethod.updatedAt,
    );
  }

  PaymentMethod toEntity() {
    return PaymentMethod(
      id: id,
      userId: userId,
      type: type,
      displayName: displayName,
      cardNumber: cardNumber,
      cardHolderName: cardHolderName,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      bankName: bankName,
      accountNumber: accountNumber,
      mobileNumber: mobileNumber,
      provider: provider,
      isDefault: isDefault,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Firebase specific factory
  factory PaymentMethodModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return PaymentMethodModel(
      id: documentId,
      userId: data['userId'] ?? '',
      type: PaymentMethodType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PaymentMethodType.cashOnDelivery,
      ),
      displayName: data['displayName'] ?? '',
      cardNumber: data['cardNumber'],
      cardHolderName: data['cardHolderName'],
      expiryMonth: data['expiryMonth'],
      expiryYear: data['expiryYear'],
      bankName: data['bankName'],
      accountNumber: data['accountNumber'],
      mobileNumber: data['mobileNumber'],
      provider: data['provider'],
      isDefault: data['isDefault'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'displayName': displayName,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'mobileNumber': mobileNumber,
      'provider': provider,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }
}
