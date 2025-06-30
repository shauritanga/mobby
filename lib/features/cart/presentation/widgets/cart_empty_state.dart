import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty cart illustration
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60.sp,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Title
            Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Subtitle
            Text(
              'Add items to your cart to get started.\nWe have great products waiting for you!',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).hintColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Action buttons
            Column(
              children: [
                // Browse products button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/products'),
                    icon: Icon(Icons.shopping_bag, size: 20.sp),
                    label: Text(
                      'Browse Products',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                // Browse categories button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/categories'),
                    icon: Icon(Icons.category, size: 20.sp),
                    label: Text(
                      'Browse Categories',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                // View wishlist button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/wishlist'),
                    icon: Icon(Icons.favorite_outline, size: 20.sp),
                    label: Text(
                      'View Wishlist',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            // Shopping tips
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Shopping Tips:',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  _buildTip(
                    context,
                    'Browse by category to find what you need',
                    Icons.category,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  _buildTip(
                    context,
                    'Add items to wishlist to save for later',
                    Icons.favorite_outline,
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  _buildTip(
                    context,
                    'Get free shipping on orders over TZS 50,000',
                    Icons.local_shipping,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class CartLoginPrompt extends StatelessWidget {
  const CartLoginPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Login illustration
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 50.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Title
            Text(
              'Sign In to View Cart',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Subtitle
            Text(
              'Create an account or sign in to save items in your cart and access them from any device.',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).hintColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Action buttons
            Column(
              children: [
                // Sign in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/login'),
                    icon: Icon(Icons.login, size: 20.sp),
                    label: Text(
                      'Sign In',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                // Create account button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/register'),
                    icon: Icon(Icons.person_add, size: 20.sp),
                    label: Text(
                      'Create Account',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Continue browsing
                TextButton(
                  onPressed: () => context.go('/products'),
                  child: Text(
                    'Continue browsing as guest',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
