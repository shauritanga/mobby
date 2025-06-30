import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Profile form field widget for consistent form styling
/// Following specifications from FEATURES_DOCUMENTATION.md
class ProfileFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String label;
  final String? hint;
  final IconData? icon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool obscureText;
  final int? maxLines;
  final String? helperText;
  final VoidCallback? onTap;

  const ProfileFormField({
    super.key,
    this.controller,
    this.initialValue,
    required this.label,
    this.hint,
    this.icon,
    this.suffix,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.helperText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        // Text Field
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          obscureText: obscureText,
          maxLines: maxLines,
          onTap: onTap,
          style: TextStyle(
            fontSize: 16.sp,
            color: enabled 
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).disabledColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).hintColor,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    size: 20.sp,
                    color: enabled 
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                  )
                : null,
            suffixIcon: suffix,
            filled: true,
            fillColor: enabled 
                ? Theme.of(context).cardColor
                : Theme.of(context).disabledColor.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: Theme.of(context).disabledColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
        
        // Helper Text
        if (helperText != null) ...[
          SizedBox(height: 4.h),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ],
    );
  }
}
