import '../models/banner_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/quick_action_model.dart';

class SampleData {
  static final DateTime now = DateTime.now();
  static final DateTime futureDate = now.add(const Duration(days: 30));

  // Sample Banners
  static List<BannerModel> get banners => [
    BannerModel(
      id: 'banner_1',
      title: 'Summer Sale',
      subtitle: 'Up to 50% off on all parts',
      imageUrl:
          'https://via.placeholder.com/350x150/1976D2/FFFFFF?text=Summer+Sale+50%25+Off',
      actionUrl: '/products?sale=true',
      actionText: 'Shop Now',
      colorHex: '#1976D2',
      priority: 1,
      isActive: true,
      createdAt: now.subtract(const Duration(days: 5)),
      expiresAt: futureDate,
    ),
    BannerModel(
      id: 'banner_2',
      title: 'Free Delivery',
      subtitle: 'On orders above \$100',
      imageUrl:
          'https://via.placeholder.com/350x150/388E3C/FFFFFF?text=Free+Delivery',
      actionUrl: '/products',
      actionText: 'Shop Now',
      colorHex: '#388E3C',
      priority: 2,
      isActive: true,
      createdAt: now.subtract(const Duration(days: 3)),
      expiresAt: futureDate,
    ),
    BannerModel(
      id: 'banner_3',
      title: 'New Arrivals',
      subtitle: 'Latest car accessories',
      imageUrl:
          'https://via.placeholder.com/350x150/FF9800/FFFFFF?text=New+Arrivals',
      actionUrl: '/products?new=true',
      actionText: 'Explore',
      colorHex: '#FF9800',
      priority: 3,
      isActive: true,
      createdAt: now.subtract(const Duration(days: 1)),
      expiresAt: futureDate,
    ),
  ];

  // Sample Categories
  static List<CategoryModel> get categories => [
    CategoryModel(
      id: 'cat_1',
      name: 'Engine Parts',
      description: 'Engine components and accessories',
      iconName: 'build',
      colorHex: '#F44336',
      sortOrder: 1,
      isActive: true,
      productCount: 156,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    CategoryModel(
      id: 'cat_2',
      name: 'Tires',
      description: 'All types of vehicle tires',
      iconName: 'tire_repair',
      colorHex: '#2196F3',
      sortOrder: 2,
      isActive: true,
      productCount: 89,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    CategoryModel(
      id: 'cat_3',
      name: 'Electrical',
      description: 'Electrical components and systems',
      iconName: 'electrical_services',
      colorHex: '#FF9800',
      sortOrder: 3,
      isActive: true,
      productCount: 234,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    CategoryModel(
      id: 'cat_4',
      name: 'Fluids',
      description: 'Engine oils, coolants, and fluids',
      iconName: 'oil_barrel',
      colorHex: '#4CAF50',
      sortOrder: 4,
      isActive: true,
      productCount: 67,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 3)),
    ),
    CategoryModel(
      id: 'cat_5',
      name: 'Body Parts',
      description: 'Exterior and interior body parts',
      iconName: 'car_crash',
      colorHex: '#9C27B0',
      sortOrder: 5,
      isActive: true,
      productCount: 123,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    CategoryModel(
      id: 'cat_6',
      name: 'Accessories',
      description: 'Car accessories and add-ons',
      iconName: 'settings',
      colorHex: '#009688',
      sortOrder: 6,
      isActive: true,
      productCount: 198,
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
  ];

  // Sample Quick Actions
  static List<QuickActionModel> get quickActions => [
    QuickActionModel(
      id: 'action_1',
      title: 'Search Parts',
      iconName: 'search',
      route: '/products',
      colorHex: '#1976D2',
      sortOrder: 1,
      isActive: true,
      requiresAuth: false,
      description: 'Search for vehicle parts',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    QuickActionModel(
      id: 'action_2',
      title: 'Add Vehicle',
      iconName: 'add_circle',
      route: '/vehicles/add',
      colorHex: '#4CAF50',
      sortOrder: 2,
      isActive: true,
      requiresAuth: true,
      description: 'Register a new vehicle',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    QuickActionModel(
      id: 'action_3',
      title: 'LATRA',
      iconName: 'assignment',
      route: '/support/latra',
      colorHex: '#FF9800',
      sortOrder: 3,
      isActive: true,
      requiresAuth: false,
      description: 'LATRA services and registration',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    QuickActionModel(
      id: 'action_4',
      title: 'Insurance',
      iconName: 'security',
      route: '/support/insurance',
      colorHex: '#9C27B0',
      sortOrder: 4,
      isActive: true,
      requiresAuth: false,
      description: 'Vehicle insurance services',
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
  ];

  // Sample Featured Products
  static List<ProductModel> get featuredProducts => [
    ProductModel(
      id: 'prod_1',
      name: 'Premium Engine Oil 5W-30',
      description: 'High-performance synthetic engine oil for modern vehicles',
      price: 114975, // TZS 114,975 (was USD 45.99)
      originalPrice: 149975, // TZS 149,975 (was USD 59.99)
      imageUrl:
          'https://via.placeholder.com/200x200/1976D2/FFFFFF?text=Engine+Oil',
      imageUrls: [
        'https://via.placeholder.com/200x200/1976D2/FFFFFF?text=Engine+Oil',
        'https://via.placeholder.com/200x200/1976D2/FFFFFF?text=Oil+2',
      ],
      categoryId: 'cat_4',
      categoryName: 'Fluids',
      brand: 'Mobil 1',
      sku: 'MOB-5W30-4L',
      stockQuantity: 50,
      rating: 4.8,
      reviewCount: 124,
      isFeatured: true,
      isActive: true,
      tags: ['synthetic', 'premium', 'engine oil'],
      specifications: {
        'viscosity': '5W-30',
        'volume': '4L',
        'type': 'Synthetic',
      },
      createdAt: now.subtract(const Duration(days: 15)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    ProductModel(
      id: 'prod_2',
      name: 'Brake Pads Set - Front',
      description:
          'High-quality ceramic brake pads for superior stopping power',
      price: 224975, // TZS 224,975 (was USD 89.99)
      imageUrl:
          'https://via.placeholder.com/200x200/F44336/FFFFFF?text=Brake+Pads',
      imageUrls: [
        'https://via.placeholder.com/200x200/F44336/FFFFFF?text=Brake+Pads',
      ],
      categoryId: 'cat_1',
      categoryName: 'Engine Parts',
      brand: 'Brembo',
      sku: 'BRE-BP-F001',
      stockQuantity: 25,
      rating: 4.7,
      reviewCount: 89,
      isFeatured: true,
      isActive: true,
      tags: ['brake', 'ceramic', 'front'],
      specifications: {
        'material': 'Ceramic',
        'position': 'Front',
        'warranty': '2 years',
      },
      createdAt: now.subtract(const Duration(days: 20)),
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    ProductModel(
      id: 'prod_3',
      name: 'LED Headlight Bulbs H7',
      description: 'Ultra-bright LED headlight bulbs with long lifespan',
      price: 87475, // TZS 87,475 (was USD 34.99)
      originalPrice: 124975, // TZS 124,975 (was USD 49.99)
      imageUrl:
          'https://via.placeholder.com/200x200/FF9800/FFFFFF?text=LED+Bulbs',
      imageUrls: [
        'https://via.placeholder.com/200x200/FF9800/FFFFFF?text=LED+Bulbs',
      ],
      categoryId: 'cat_3',
      categoryName: 'Electrical',
      brand: 'Philips',
      sku: 'PHI-LED-H7',
      stockQuantity: 75,
      rating: 4.6,
      reviewCount: 156,
      isFeatured: true,
      isActive: true,
      tags: ['LED', 'headlight', 'H7'],
      specifications: {
        'type': 'H7',
        'power': '25W',
        'lumens': '6000',
        'color': '6000K',
      },
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    ProductModel(
      id: 'prod_4',
      name: 'All-Season Tire 205/55R16',
      description:
          'Durable all-season tire with excellent grip and fuel efficiency',
      price: 324975, // TZS 324,975 (was USD 129.99)
      imageUrl: 'https://via.placeholder.com/200x200/2196F3/FFFFFF?text=Tire',
      imageUrls: [
        'https://via.placeholder.com/200x200/2196F3/FFFFFF?text=Tire',
      ],
      categoryId: 'cat_2',
      categoryName: 'Tires',
      brand: 'Michelin',
      sku: 'MIC-AS-205-55-16',
      stockQuantity: 40,
      rating: 4.9,
      reviewCount: 203,
      isFeatured: true,
      isActive: true,
      tags: ['all-season', 'fuel-efficient', '205/55R16'],
      specifications: {
        'size': '205/55R16',
        'season': 'All-Season',
        'load_index': '91',
        'speed_rating': 'V',
      },
      createdAt: now.subtract(const Duration(days: 25)),
      updatedAt: now.subtract(const Duration(days: 3)),
    ),
    ProductModel(
      id: 'prod_5',
      name: 'Car Air Freshener Set',
      description: 'Premium car air freshener with long-lasting fragrance',
      price: 32475, // TZS 32,475 (was USD 12.99)
      imageUrl:
          'https://via.placeholder.com/200x200/009688/FFFFFF?text=Air+Freshener',
      imageUrls: [
        'https://via.placeholder.com/200x200/009688/FFFFFF?text=Air+Freshener',
      ],
      categoryId: 'cat_6',
      categoryName: 'Accessories',
      brand: 'Little Trees',
      sku: 'LT-AF-SET-001',
      stockQuantity: 100,
      rating: 4.3,
      reviewCount: 67,
      isFeatured: true,
      isActive: true,
      tags: ['air freshener', 'fragrance', 'accessories'],
      specifications: {
        'quantity': '3 pieces',
        'fragrance': 'New Car',
        'duration': '30 days',
      },
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
  ];
}
