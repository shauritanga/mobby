import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/category.dart';

class SubcategoryChips extends StatelessWidget {
  final List<Category> subcategories;
  final String? selectedSubcategoryId;
  final ValueChanged<String?> onSubcategorySelected;
  final bool showAllOption;

  const SubcategoryChips({
    super.key,
    required this.subcategories,
    this.selectedSubcategoryId,
    required this.onSubcategorySelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    if (subcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subcategories',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // All subcategories option
                if (showAllOption)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _buildSubcategoryChip(
                      context,
                      'All',
                      null,
                      selectedSubcategoryId == null,
                      null,
                    ),
                  ),
                
                // Individual subcategory chips
                ...subcategories.map((subcategory) {
                  final isSelected = selectedSubcategoryId == subcategory.id;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _buildSubcategoryChip(
                      context,
                      subcategory.name,
                      subcategory.id,
                      isSelected,
                      subcategory.productCount,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryChip(
    BuildContext context,
    String label,
    String? subcategoryId,
    bool isSelected,
    int? productCount,
  ) {
    return GestureDetector(
      onTap: () => onSubcategorySelected(subcategoryId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? Colors.white 
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            
            if (productCount != null) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.2)
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  productCount.toString(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? Colors.white 
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SubcategoryGrid extends StatelessWidget {
  final List<Category> subcategories;
  final ValueChanged<Category> onSubcategoryTap;

  const SubcategoryGrid({
    super.key,
    required this.subcategories,
    required this.onSubcategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (subcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse Subcategories',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: subcategories.length,
            itemBuilder: (context, index) {
              final subcategory = subcategories[index];
              return _buildSubcategoryCard(context, subcategory);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryCard(BuildContext context, Category subcategory) {
    return GestureDetector(
      onTap: () => onSubcategoryTap(subcategory),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Subcategory icon
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getSubcategoryIcon(subcategory.name),
                  size: 24.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              SizedBox(height: 12.h),
              
              // Subcategory name
              Text(
                subcategory.name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 4.h),
              
              // Product count
              if (subcategory.productCount != null)
                Text(
                  '${subcategory.productCount} items',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSubcategoryIcon(String subcategoryName) {
    // Map subcategory names to appropriate icons
    switch (subcategoryName.toLowerCase()) {
      case 'pistons':
        return Icons.circle;
      case 'valves':
        return Icons.tune;
      case 'gaskets':
        return Icons.donut_small;
      case 'filters':
        return Icons.filter_alt;
      case 'spark plugs':
        return Icons.flash_on;
      case 'brake pads':
        return Icons.disc_full;
      case 'brake discs':
        return Icons.album;
      case 'brake fluid':
        return Icons.opacity;
      case 'shocks':
        return Icons.height;
      case 'springs':
        return Icons.waves;
      case 'struts':
        return Icons.vertical_align_center;
      case 'lights':
        return Icons.lightbulb;
      case 'wiring':
        return Icons.cable;
      case 'batteries':
        return Icons.battery_full;
      case 'alternators':
        return Icons.electrical_services;
      case 'doors':
        return Icons.door_front_door;
      case 'bumpers':
        return Icons.shield;
      case 'mirrors':
        return Icons.visibility;
      case 'seats':
        return Icons.airline_seat_recline_normal;
      case 'dashboard':
        return Icons.dashboard;
      case 'steering wheel':
        return Icons.sports_esports;
      default:
        return Icons.category;
    }
  }
}

class SubcategoryList extends StatelessWidget {
  final List<Category> subcategories;
  final ValueChanged<Category> onSubcategoryTap;
  final String? selectedSubcategoryId;

  const SubcategoryList({
    super.key,
    required this.subcategories,
    required this.onSubcategoryTap,
    this.selectedSubcategoryId,
  });

  @override
  Widget build(BuildContext context) {
    if (subcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: subcategories.map((subcategory) {
          final isSelected = selectedSubcategoryId == subcategory.id;
          
          return ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _getSubcategoryIcon(subcategory.name),
                size: 20.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              subcategory.name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: subcategory.productCount != null
                ? Text('${subcategory.productCount} products')
                : null,
            trailing: isSelected 
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).primaryColor,
                  )
                : const Icon(Icons.chevron_right),
            onTap: () => onSubcategoryTap(subcategory),
            selected: isSelected,
            selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.05),
          );
        }).toList(),
      ),
    );
  }

  IconData _getSubcategoryIcon(String subcategoryName) {
    // Same icon mapping as in SubcategoryGrid
    switch (subcategoryName.toLowerCase()) {
      case 'pistons':
        return Icons.circle;
      case 'valves':
        return Icons.tune;
      case 'gaskets':
        return Icons.donut_small;
      case 'filters':
        return Icons.filter_alt;
      case 'spark plugs':
        return Icons.flash_on;
      case 'brake pads':
        return Icons.disc_full;
      case 'brake discs':
        return Icons.album;
      case 'brake fluid':
        return Icons.opacity;
      case 'shocks':
        return Icons.height;
      case 'springs':
        return Icons.waves;
      case 'struts':
        return Icons.vertical_align_center;
      case 'lights':
        return Icons.lightbulb;
      case 'wiring':
        return Icons.cable;
      case 'batteries':
        return Icons.battery_full;
      case 'alternators':
        return Icons.electrical_services;
      case 'doors':
        return Icons.door_front_door;
      case 'bumpers':
        return Icons.shield;
      case 'mirrors':
        return Icons.visibility;
      case 'seats':
        return Icons.airline_seat_recline_normal;
      case 'dashboard':
        return Icons.dashboard;
      case 'steering wheel':
        return Icons.sports_esports;
      default:
        return Icons.category;
    }
  }
}
