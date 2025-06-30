import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductListAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final bool isGridView;
  final VoidCallback onToggleView;

  const ProductListAppBar({
    super.key,
    required this.title,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.isGridView,
    required this.onToggleView,
  });

  @override
  State<ProductListAppBar> createState() => _ProductListAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (searchQuery.isNotEmpty ? 60.h : 0));
}

class _ProductListAppBarState extends State<ProductListAppBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
    _isSearchExpanded = widget.searchQuery.isNotEmpty;
  }

  @override
  void didUpdateWidget(ProductListAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _searchController.text = widget.searchQuery;
      _isSearchExpanded = widget.searchQuery.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchFocusNode.requestFocus();
      } else {
        _searchFocusNode.unfocus();
        _searchController.clear();
        widget.onSearchClear();
      }
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      widget.onSearchChanged(query.trim());
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearchExpanded ? null : Text(
        widget.title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: !_isSearchExpanded,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      leading: _isSearchExpanded ? null : IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (_isSearchExpanded) ...[
          // Expanded search bar
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).hintColor,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20.sp,
                    color: Theme.of(context).hintColor,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchClear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                style: TextStyle(fontSize: 16.sp),
                textInputAction: TextInputAction.search,
                onSubmitted: _onSearchSubmitted,
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide clear button
                },
              ),
            ),
          ),
          
          // Close search button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _toggleSearch,
          ),
        ] else ...[
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
            tooltip: 'Search products',
          ),
          
          // View toggle button
          IconButton(
            icon: Icon(
              widget.isGridView ? Icons.view_list : Icons.grid_view,
            ),
            onPressed: widget.onToggleView,
            tooltip: widget.isGridView ? 'List view' : 'Grid view',
          ),
          
          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'wishlist':
                  // Navigate to wishlist
                  break;
                case 'compare':
                  // Navigate to compare
                  break;
                case 'recent':
                  // Show recently viewed
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'wishlist',
                child: ListTile(
                  leading: Icon(Icons.favorite_outline),
                  title: Text('Wishlist'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'compare',
                child: ListTile(
                  leading: Icon(Icons.compare_arrows),
                  title: Text('Compare'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'recent',
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Recently Viewed'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ],
      bottom: _isSearchExpanded && widget.searchQuery.isNotEmpty
          ? PreferredSize(
              preferredSize: Size.fromHeight(40.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 16.sp,
                      color: Theme.of(context).hintColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Searching for "${widget.searchQuery}"',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onSearchClear,
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
