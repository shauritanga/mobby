# Feature Structure Template

## 📁 Clean Architecture Structure Template

Each feature follows this exact structure pattern:

```
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   │   ├── [feature]_local_datasource.dart
│   │   └── [feature]_remote_datasource.dart
│   ├── models/
│   │   └── [entity]_model.dart
│   └── repositories/
│       └── [feature]_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── [entity].dart
│   ├── repositories/
│   │   └── [feature]_repository.dart
│   └── usecases/
│       ├── [action1]_usecase.dart
│       ├── [action2]_usecase.dart
│       └── [action3]_usecase.dart
└── presentation/
    ├── providers/
    │   ├── [feature]_provider.dart
    │   └── [feature]_state_provider.dart
    ├── screens/
    │   ├── [screen1]_screen.dart
    │   ├── [screen2]_screen.dart
    │   └── [screen3]_screen.dart
    ├── states/
    │   └── [feature]_state.dart
    └── widgets/
        ├── [widget1].dart
        ├── [widget2].dart
        └── [widget3].dart
```

## 🔧 Example: Product Catalog Feature Structure

```
lib/features/product_catalog/
├── data/
│   ├── datasources/
│   │   ├── product_local_datasource.dart
│   │   └── product_remote_datasource.dart
│   ├── models/
│   │   ├── product_model.dart
│   │   ├── category_model.dart
│   │   └── review_model.dart
│   └── repositories/
│       └── product_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── product.dart
│   │   ├── category.dart
│   │   └── review.dart
│   ├── repositories/
│   │   └── product_repository.dart
│   └── usecases/
│       ├── get_products_usecase.dart
│       ├── get_categories_usecase.dart
│       ├── search_products_usecase.dart
│       ├── get_product_details_usecase.dart
│       └── filter_products_usecase.dart
└── presentation/
    ├── providers/
    │   ├── product_provider.dart
    │   ├── category_provider.dart
    │   └── search_provider.dart
    ├── screens/
    │   ├── categories_screen.dart
    │   ├── product_list_screen.dart
    │   ├── product_details_screen.dart
    │   └── search_screen.dart
    ├── states/
    │   ├── product_state.dart
    │   ├── category_state.dart
    │   └── search_state.dart
    └── widgets/
        ├── product_card.dart
        ├── category_tile.dart
        ├── product_image_gallery.dart
        ├── product_specifications.dart
        ├── review_list.dart
        └── filter_bottom_sheet.dart
```

## 📋 Implementation Checklist for Each Feature

### ✅ Domain Layer (Business Logic)
- [ ] Define entities (pure Dart classes)
- [ ] Create repository interfaces
- [ ] Implement use cases with business rules
- [ ] Add error handling and validation

### ✅ Data Layer (External Concerns)
- [ ] Create data models (extend entities)
- [ ] Implement remote data sources (API calls)
- [ ] Implement local data sources (caching)
- [ ] Create repository implementations
- [ ] Add data transformation logic

### ✅ Presentation Layer (UI & State)
- [ ] Define state classes
- [ ] Create Riverpod providers
- [ ] Build screen widgets
- [ ] Create reusable UI components
- [ ] Add navigation logic
- [ ] Implement error handling UI

### ✅ Testing
- [ ] Unit tests for use cases
- [ ] Unit tests for repositories
- [ ] Widget tests for screens
- [ ] Widget tests for components
- [ ] Integration tests for flows

## 🎯 Riverpod Provider Patterns

### State Providers
```dart
// For simple state management
final counterProvider = StateProvider<int>((ref) => 0);
```

### StateNotifier Providers
```dart
// For complex state management
final productProvider = StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(ref.read(productRepositoryProvider)),
);
```

### Future Providers
```dart
// For async operations
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getProducts();
});
```

### Stream Providers
```dart
// For real-time data
final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  final repository = ref.read(orderRepositoryProvider);
  return repository.getOrdersStream();
});
```

## 🔄 Data Flow Pattern

1. **UI Event** → Screen/Widget
2. **Action** → Provider (StateNotifier)
3. **Business Logic** → Use Case
4. **Data Access** → Repository
5. **External Data** → Data Source (API/Local)
6. **Response** → Back through the chain
7. **State Update** → UI Rebuilds

## 📱 Screen Navigation Pattern

```dart
// Using go_router for navigation
context.go('/products');
context.push('/product/${productId}');
context.pop();
```

## 🎨 Widget Composition Pattern

- **Screens**: Full-page widgets
- **Widgets**: Reusable components
- **Components**: Atomic UI elements

## 🔐 Error Handling Pattern

```dart
// Consistent error handling across features
sealed class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductLoaded extends ProductState {
  final List<Product> products;
  const ProductLoaded(this.products);
}
class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
}
```

This template ensures consistency across all features while maintaining clean architecture principles and proper separation of concerns.
