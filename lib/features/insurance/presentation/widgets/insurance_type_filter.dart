import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/insurance_provider.dart';

class InsuranceTypeFilter extends StatelessWidget {
  final List<ProviderType> selectedTypes;
  final Function(List<ProviderType>) onTypesChanged;

  const InsuranceTypeFilter({
    super.key,
    required this.selectedTypes,
    required this.onTypesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All types chip
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text('All'),
              selected: selectedTypes.isEmpty,
              onSelected: (selected) {
                if (selected) {
                  onTypesChanged([]);
                }
              },
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                fontSize: 12.sp,
                color: selectedTypes.isEmpty
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
              side: BorderSide(
                color: selectedTypes.isEmpty
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),

          // Individual type chips
          ...ProviderType.values.map((type) {
            final isSelected = selectedTypes.contains(type);
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      size: 14.r,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 4.w),
                    Text(_getTypeDisplayName(type)),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  final newTypes = List<ProviderType>.from(selectedTypes);
                  if (selected) {
                    newTypes.add(type);
                  } else {
                    newTypes.remove(type);
                  }
                  onTypesChanged(newTypes);
                },
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
                labelStyle: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getTypeIcon(ProviderType type) {
    switch (type) {
      case ProviderType.automotive:
        return Icons.directions_car;
      case ProviderType.health:
        return Icons.local_hospital;
      case ProviderType.life:
        return Icons.favorite;
      case ProviderType.property:
        return Icons.home;
      case ProviderType.travel:
        return Icons.flight;
      case ProviderType.business:
        return Icons.business;
    }
  }

  String _getTypeDisplayName(ProviderType type) {
    switch (type) {
      case ProviderType.automotive:
        return 'Auto';
      case ProviderType.health:
        return 'Health';
      case ProviderType.life:
        return 'Life';
      case ProviderType.property:
        return 'Property';
      case ProviderType.travel:
        return 'Travel';
      case ProviderType.business:
        return 'Business';
    }
  }
}
