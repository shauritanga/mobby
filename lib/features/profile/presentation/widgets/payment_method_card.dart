import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/payment_method.dart';

/// Payment method card widget for displaying payment method information
/// Following specifications from FEATURES_DOCUMENTATION.md
class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;
  final bool showActions;

  const PaymentMethodCard({
    super.key,
    required this.paymentMethod,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Header
              Row(
                children: [
                  // Payment Method Icon
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: _getPaymentMethodColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getPaymentMethodIcon(),
                      size: 20.sp,
                      color: _getPaymentMethodColor(),
                    ),
                  ),
                  
                  SizedBox(width: 12.w),
                  
                  // Payment Method Type and Default Badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              paymentMethod.type.displayName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.titleMedium?.color,
                              ),
                            ),
                            if (paymentMethod.isDefault) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          paymentMethod.displayName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Expired Badge
                  if (paymentMethod.isExpired)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Expired',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  
                  SizedBox(width: 8.w),
                  
                  // Actions Menu
                  if (showActions)
                    PopupMenuButton<String>(
                      onSelected: _handleAction,
                      itemBuilder: (context) => [
                        if (!paymentMethod.isDefault && onSetDefault != null)
                          const PopupMenuItem(
                            value: 'set_default',
                            child: ListTile(
                              leading: Icon(Icons.star),
                              title: Text('Set as Default'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete', style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                      child: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              // Payment Method Details
              Text(
                paymentMethod.maskedDisplayText,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  letterSpacing: 1.2,
                ),
              ),
              
              SizedBox(height: 8.h),
              
              // Additional Details
              _buildAdditionalDetails(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalDetails(BuildContext context) {
    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
      case PaymentMethodType.debitCard:
        return Row(
          children: [
            if (paymentMethod.cardHolderName != null) ...[
              Icon(
                Icons.person,
                size: 16.sp,
                color: Theme.of(context).hintColor,
              ),
              SizedBox(width: 4.w),
              Text(
                paymentMethod.cardHolderName!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
            if (paymentMethod.expiryMonth != null && paymentMethod.expiryYear != null) ...[
              const Spacer(),
              Text(
                'Expires ${paymentMethod.expiryMonth}/${paymentMethod.expiryYear}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: paymentMethod.isExpired 
                      ? Colors.red 
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ],
        );
        
      case PaymentMethodType.bankAccount:
        return Row(
          children: [
            Icon(
              Icons.account_balance,
              size: 16.sp,
              color: Theme.of(context).hintColor,
            ),
            SizedBox(width: 4.w),
            Text(
              paymentMethod.bankName ?? 'Bank Account',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        );
        
      case PaymentMethodType.mobileMoney:
        return Row(
          children: [
            Icon(
              Icons.phone_android,
              size: 16.sp,
              color: Theme.of(context).hintColor,
            ),
            SizedBox(width: 4.w),
            Text(
              paymentMethod.provider ?? 'Mobile Money',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            if (paymentMethod.mobileNumber != null) ...[
              const Spacer(),
              Text(
                paymentMethod.mobileNumber!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ],
        );
        
      case PaymentMethodType.cashOnDelivery:
        return Row(
          children: [
            Icon(
              Icons.money,
              size: 16.sp,
              color: Theme.of(context).hintColor,
            ),
            SizedBox(width: 4.w),
            Text(
              'Pay when you receive your order',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        );
    }
  }

  IconData _getPaymentMethodIcon() {
    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
        return Icons.credit_card;
      case PaymentMethodType.debitCard:
        return Icons.payment;
      case PaymentMethodType.bankAccount:
        return Icons.account_balance;
      case PaymentMethodType.mobileMoney:
        return Icons.phone_android;
      case PaymentMethodType.cashOnDelivery:
        return Icons.money;
    }
  }

  Color _getPaymentMethodColor() {
    switch (paymentMethod.type) {
      case PaymentMethodType.creditCard:
        return Colors.purple;
      case PaymentMethodType.debitCard:
        return Colors.blue;
      case PaymentMethodType.bankAccount:
        return Colors.green;
      case PaymentMethodType.mobileMoney:
        return Colors.orange;
      case PaymentMethodType.cashOnDelivery:
        return Colors.brown;
    }
  }

  void _handleAction(String action) {
    switch (action) {
      case 'set_default':
        onSetDefault?.call();
        break;
      case 'edit':
        onEdit?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }
}
