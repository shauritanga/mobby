import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Settings switch tile widget for boolean preferences
/// Following specifications from FEATURES_DOCUMENTATION.md
class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? iconColor;
  final bool enabled;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.iconColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = enabled 
        ? (iconColor ?? Theme.of(context).primaryColor)
        : Theme.of(context).disabledColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled && onChanged != null 
            ? () => onChanged!(!value)
            : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  size: 20.sp,
                  color: effectiveIconColor,
                ),
              ),
              
              SizedBox(width: 12.w),
              
              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: enabled 
                            ? Theme.of(context).textTheme.titleMedium?.color
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: enabled 
                              ? Theme.of(context).textTheme.bodySmall?.color
                              : Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(width: 8.w),
              
              // Switch
              Switch(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
