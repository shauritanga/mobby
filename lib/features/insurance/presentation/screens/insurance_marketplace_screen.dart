import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/insurance_provider.dart';
import '../providers/insurance_providers.dart';
import '../widgets/provider_card.dart';
import '../widgets/insurance_type_filter.dart';
import '../widgets/provider_search_bar.dart';
import '../widgets/featured_providers_section.dart';
import '../widgets/insurance_stats_card.dart';

class InsuranceMarketplaceScreen extends ConsumerStatefulWidget {
  const InsuranceMarketplaceScreen({super.key});

  @override
  ConsumerState<InsuranceMarketplaceScreen> createState() => _InsuranceMarketplaceScreenState();
}

class _InsuranceMarketplaceScreenState extends ConsumerState<InsuranceMarketplaceScreen> {
  final ScrollController _scrollController = ScrollController();
  List<ProviderType>? _selectedTypes;
  String? _searchQuery;
  double? _minRating;
  double? _maxPremium;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load providers when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(insuranceProvidersProvider.notifier).loadProviders();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(insuranceProvidersProvider.notifier).loadMoreProviders();
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
    });
    _applyFilters();
  }

  void _onTypeFilterChanged(List<ProviderType> types) {
    setState(() {
      _selectedTypes = types.isEmpty ? null : types;
    });
    _applyFilters();
  }

  void _applyFilters() {
    ref.read(insuranceProvidersProvider.notifier).searchProviders(
      query: _searchQuery,
      types: _selectedTypes,
      minRating: _minRating,
      maxPremium: _maxPremium,
    );
  }

  void _navigateToProviderDetails(String providerId) {
    context.push('/insurance/providers/$providerId');
  }

  void _navigateToQuoteComparison() {
    context.push('/insurance/compare');
  }

  void _navigateToApplication() {
    context.push('/insurance/apply');
  }

  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(insuranceProvidersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120.h,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Insurance Marketplace',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 16.w, bottom: 16.h),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.compare_arrows,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: _navigateToQuoteComparison,
                tooltip: 'Compare Quotes',
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: _navigateToApplication,
                tooltip: 'Apply for Insurance',
              ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.w),
              color: Theme.of(context).colorScheme.surface,
              child: ProviderSearchBar(
                onSearch: _onSearch,
                hintText: 'Search insurance providers...',
              ),
            ),
          ),

          // Insurance Type Filter
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: Theme.of(context).colorScheme.surface,
              child: InsuranceTypeFilter(
                selectedTypes: _selectedTypes ?? [],
                onTypesChanged: _onTypeFilterChanged,
              ),
            ),
          ),

          // Insurance Statistics
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: const InsuranceStatsCard(),
            ),
          ),

          // Featured Providers Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const FeaturedProvidersSection(),
            ),
          ),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Providers',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Show filter bottom sheet
                    },
                    icon: Icon(
                      Icons.tune,
                      size: 16.r,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    label: Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Providers List
          providersAsync.when(
            data: (providersState) => _buildProvidersList(providersState),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildProvidersList(InsuranceProvidersState providersState) {
    if (providersState.providers.isEmpty && !providersState.isLoading) {
      return _buildEmptyState();
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= providersState.providers.length) {
            return _buildLoadingIndicator();
          }

          final provider = providersState.providers[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: ProviderCard(
              provider: provider,
              onTap: () => _navigateToProviderDetails(provider.id),
            ),
          );
        },
        childCount: providersState.providers.length + (providersState.isLoading ? 1 : 0),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: _buildProviderCardSkeleton(),
        ),
        childCount: 5,
      ),
    );
  }

  Widget _buildProviderCardSkeleton() {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 80.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              height: 12.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 200.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security_outlined,
                size: 64.r,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: 16.h),
              Text(
                'No Insurance Providers Found',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Try adjusting your search criteria\nor check back later for new providers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => ref.read(insuranceProvidersProvider.notifier).loadProviders(refresh: true),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.r,
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error Loading Providers',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => ref.read(insuranceProvidersProvider.notifier).loadProviders(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
