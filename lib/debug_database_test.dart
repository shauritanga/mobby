import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Simple debug screen to test database connectivity and data fetching
class DebugDatabaseTest extends StatefulWidget {
  const DebugDatabaseTest({super.key});

  @override
  State<DebugDatabaseTest> createState() => _DebugDatabaseTestState();
}

class _DebugDatabaseTestState extends State<DebugDatabaseTest> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _output = 'Ready to test...';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Debug Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testCategories,
              child: const Text('Test Categories'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testProducts,
              child: const Text('Test Products'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testFeaturedProducts,
              child: const Text('Test Featured Products'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _output,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _testCategories() async {
    setState(() {
      _isLoading = true;
      _output = 'Testing categories...\n';
    });

    try {
      // Test basic categories query
      final querySnapshot = await _firestore.collection('categories').get();
      _appendOutput(
        'Total categories in database: ${querySnapshot.docs.length}\n',
      );

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        _appendOutput('Category: ${doc.id}\n');
        _appendOutput('  Name: ${data['name']}\n');
        _appendOutput('  IsActive: ${data['isActive']}\n');
        _appendOutput('  SortOrder: ${data['sortOrder']}\n');
        _appendOutput('  ParentId: ${data['parentId']}\n\n');
      }

      // Test active categories query
      final activeQuery = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .get();
      _appendOutput('Active categories: ${activeQuery.docs.length}\n\n');
    } catch (e) {
      _appendOutput('Error testing categories: $e\n');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testProducts() async {
    setState(() {
      _isLoading = true;
      _output = 'Testing products...\n';
    });

    try {
      // Test basic products query
      final querySnapshot = await _firestore.collection('products').get();
      _appendOutput(
        'Total products in database: ${querySnapshot.docs.length}\n',
      );

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        _appendOutput('Product: ${doc.id}\n');
        _appendOutput('  Name: ${data['name']}\n');
        _appendOutput('  IsActive: ${data['isActive']}\n');
        _appendOutput('  IsFeatured: ${data['isFeatured']}\n');
        _appendOutput('  CategoryId: ${data['categoryId']}\n');
        _appendOutput('  StockQuantity: ${data['stockQuantity']}\n');
        _appendOutput('  Rating: ${data['rating']}\n\n');
      }
    } catch (e) {
      _appendOutput('Error testing products: $e\n');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testFeaturedProducts() async {
    setState(() {
      _isLoading = true;
      _output = 'Testing featured products...\n';
    });

    try {
      // Test featured products query
      final querySnapshot = await _firestore
          .collection('products')
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      _appendOutput('Featured products found: ${querySnapshot.docs.length}\n');

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        _appendOutput('Featured Product: ${doc.id}\n');
        _appendOutput('  Name: ${data['name']}\n');
        _appendOutput('  IsActive: ${data['isActive']}\n');
        _appendOutput('  IsFeatured: ${data['isFeatured']}\n');
        _appendOutput('  CategoryId: ${data['categoryId']}\n');
        _appendOutput('  StockQuantity: ${data['stockQuantity']}\n');
        _appendOutput('  Rating: ${data['rating']}\n\n');
      }
    } catch (e) {
      _appendOutput('Error testing featured products: $e\n');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _appendOutput(String text) {
    setState(() {
      _output += text;
    });
  }
}

/// Function to show the debug screen
void showDatabaseDebugTest(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => const DebugDatabaseTest()));
}
