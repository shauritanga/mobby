import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final String hintText;
  final bool autofocus;
  final Widget? leading;
  final List<Widget>? actions;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClear,
    this.hintText = 'Search...',
    this.autofocus = false,
    this.leading,
    this.actions,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChange() {
    setState(() {}); // Rebuild to show/hide clear button
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: widget.focusNode.hasFocus
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
                width: widget.focusNode.hasFocus ? 2 : 1,
              ),
              boxShadow: widget.focusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Leading icon
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: widget.leading ??
                      Icon(
                        Icons.search,
                        size: 20.sp,
                        color: widget.focusNode.hasFocus
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).hintColor,
                      ),
                ),
                
                // Text field
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    autofocus: widget.autofocus,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        fontSize: 16.sp,
                        color: Theme.of(context).hintColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: widget.onSubmitted,
                  ),
                ),
                
                // Clear button
                if (widget.controller.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: GestureDetector(
                      onTap: () {
                        widget.controller.clear();
                        widget.onClear();
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).hintColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
                
                // Actions
                if (widget.actions != null) ...widget.actions!,
                
                SizedBox(width: 8.w),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SearchBarWithVoice extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback? onVoiceSearch;
  final String hintText;

  const SearchBarWithVoice({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClear,
    this.onVoiceSearch,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return SearchBarWidget(
      controller: controller,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      onClear: onClear,
      hintText: hintText,
      actions: [
        if (onVoiceSearch != null)
          GestureDetector(
            onTap: onVoiceSearch,
            child: Container(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.mic,
                size: 20.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}

class CompactSearchBar extends StatelessWidget {
  final String? query;
  final VoidCallback onTap;
  final String hintText;

  const CompactSearchBar({
    super.key,
    this.query,
    required this.onTap,
    this.hintText = 'Search products...',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 20.sp,
              color: Theme.of(context).hintColor,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                query?.isNotEmpty == true ? query! : hintText,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: query?.isNotEmpty == true
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Theme.of(context).hintColor,
                ),
              ),
            ),
            if (query?.isNotEmpty == true)
              Icon(
                Icons.close,
                size: 20.sp,
                color: Theme.of(context).hintColor,
              ),
          ],
        ),
      ),
    );
  }
}

class SearchBarWithFilters extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;
  final bool hasActiveFilters;
  final int activeFilterCount;
  final String hintText;

  const SearchBarWithFilters({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClear,
    required this.onFilterTap,
    this.hasActiveFilters = false,
    this.activeFilterCount = 0,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarWidget(
          controller: controller,
          focusNode: focusNode,
          onSubmitted: onSubmitted,
          onClear: onClear,
          hintText: hintText,
          actions: [
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: Stack(
                  children: [
                    Icon(
                      Icons.tune,
                      size: 20.sp,
                      color: hasActiveFilters
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).hintColor,
                    ),
                    if (hasActiveFilters && activeFilterCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16.w,
                            minHeight: 16.w,
                          ),
                          child: Text(
                            activeFilterCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // Active filters indicator
        if (hasActiveFilters)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            margin: EdgeInsets.only(top: 8.h),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list,
                  size: 16.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8.w),
                Text(
                  '$activeFilterCount filter${activeFilterCount > 1 ? 's' : ''} active',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onFilterTap,
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
