// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_filter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchResultsHash() => r'6faae5c57ca9142421ddc71157e54fdb10c5ff2e';

/// See also [searchResults].
@ProviderFor(searchResults)
final searchResultsProvider =
    AutoDisposeFutureProvider<ProductSearchResult>.internal(
  searchResults,
  name: r'searchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchResultsRef = AutoDisposeFutureProviderRef<ProductSearchResult>;
String _$searchSuggestionsForQueryHash() =>
    r'c8fc0da92c0dd169022679e97b8e757973ea61a5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [searchSuggestionsForQuery].
@ProviderFor(searchSuggestionsForQuery)
const searchSuggestionsForQueryProvider = SearchSuggestionsForQueryFamily();

/// See also [searchSuggestionsForQuery].
class SearchSuggestionsForQueryFamily extends Family<AsyncValue<List<String>>> {
  /// See also [searchSuggestionsForQuery].
  const SearchSuggestionsForQueryFamily();

  /// See also [searchSuggestionsForQuery].
  SearchSuggestionsForQueryProvider call(
    String query,
  ) {
    return SearchSuggestionsForQueryProvider(
      query,
    );
  }

  @override
  SearchSuggestionsForQueryProvider getProviderOverride(
    covariant SearchSuggestionsForQueryProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchSuggestionsForQueryProvider';
}

/// See also [searchSuggestionsForQuery].
class SearchSuggestionsForQueryProvider
    extends AutoDisposeFutureProvider<List<String>> {
  /// See also [searchSuggestionsForQuery].
  SearchSuggestionsForQueryProvider(
    String query,
  ) : this._internal(
          (ref) => searchSuggestionsForQuery(
            ref as SearchSuggestionsForQueryRef,
            query,
          ),
          from: searchSuggestionsForQueryProvider,
          name: r'searchSuggestionsForQueryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchSuggestionsForQueryHash,
          dependencies: SearchSuggestionsForQueryFamily._dependencies,
          allTransitiveDependencies:
              SearchSuggestionsForQueryFamily._allTransitiveDependencies,
          query: query,
        );

  SearchSuggestionsForQueryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(SearchSuggestionsForQueryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchSuggestionsForQueryProvider._internal(
        (ref) => create(ref as SearchSuggestionsForQueryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _SearchSuggestionsForQueryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchSuggestionsForQueryProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchSuggestionsForQueryRef
    on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchSuggestionsForQueryProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with SearchSuggestionsForQueryRef {
  _SearchSuggestionsForQueryProviderElement(super.provider);

  @override
  String get query => (origin as SearchSuggestionsForQueryProvider).query;
}

String _$activeSearchAndFilterHash() =>
    r'67c7267ab06aaff8d92fe90068f7781d08edfb77';

/// See also [activeSearchAndFilter].
@ProviderFor(activeSearchAndFilter)
final activeSearchAndFilterProvider =
    AutoDisposeFutureProvider<ProductSearchResult>.internal(
  activeSearchAndFilter,
  name: r'activeSearchAndFilterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSearchAndFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSearchAndFilterRef
    = AutoDisposeFutureProviderRef<ProductSearchResult>;
String _$searchStateHash() => r'5182fd6d790ae8283dd0dab3a2f3e655342115fc';

/// See also [SearchState].
@ProviderFor(SearchState)
final searchStateProvider =
    AutoDisposeNotifierProvider<SearchState, String>.internal(
  SearchState.new,
  name: r'searchStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchState = AutoDisposeNotifier<String>;
String _$filterStateHash() => r'49a89e75463db7fda672bdc8dea8aad0f4f62967';

/// See also [FilterState].
@ProviderFor(FilterState)
final filterStateProvider =
    AutoDisposeNotifierProvider<FilterState, ProductFilter>.internal(
  FilterState.new,
  name: r'filterStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$filterStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FilterState = AutoDisposeNotifier<ProductFilter>;
String _$paginationStateHash() => r'2935f2b45e9be93ab72053cc7c9dd61cb21bff7d';

/// See also [PaginationState].
@ProviderFor(PaginationState)
final paginationStateProvider =
    AutoDisposeNotifierProvider<PaginationState, Map<String, dynamic>>.internal(
  PaginationState.new,
  name: r'paginationStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paginationStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PaginationState = AutoDisposeNotifier<Map<String, dynamic>>;
String _$searchHistoryStateHash() =>
    r'a048dcc351ae3e220bd321e9a5ff480c747f2913';

/// See also [SearchHistoryState].
@ProviderFor(SearchHistoryState)
final searchHistoryStateProvider =
    AutoDisposeNotifierProvider<SearchHistoryState, List<String>>.internal(
  SearchHistoryState.new,
  name: r'searchHistoryStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchHistoryStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchHistoryState = AutoDisposeNotifier<List<String>>;
String _$quickFiltersHash() => r'cd145f9619c54d6c1d3c68297713b7f0316d930f';

/// See also [QuickFilters].
@ProviderFor(QuickFilters)
final quickFiltersProvider = AutoDisposeNotifierProvider<QuickFilters,
    Map<String, ProductFilter>>.internal(
  QuickFilters.new,
  name: r'quickFiltersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$quickFiltersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuickFilters = AutoDisposeNotifier<Map<String, ProductFilter>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
