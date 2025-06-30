import '../../features/auth/domain/entities/user.dart';

enum UserRole {
  client,
  admin,
  superAdmin,
}

class RoleHelper {
  // Determine user role based on user data
  static UserRole getUserRole(User user) {
    // For now, we'll use email domain to determine role
    // In a real app, this would come from user properties or database
    
    if (user.email.endsWith('@mobby-admin.com')) {
      return UserRole.superAdmin;
    } else if (user.email.endsWith('@mobby.com')) {
      return UserRole.admin;
    } else {
      return UserRole.client;
    }
  }

  // Check if user has admin privileges
  static bool isAdmin(User user) {
    final role = getUserRole(user);
    return role == UserRole.admin || role == UserRole.superAdmin;
  }

  // Check if user is super admin
  static bool isSuperAdmin(User user) {
    return getUserRole(user) == UserRole.superAdmin;
  }

  // Get default route based on user role
  static String getDefaultRoute(User user) {
    if (isAdmin(user)) {
      return '/admin/dashboard';
    } else {
      return '/home';
    }
  }

  // Get role display name
  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.client:
        return 'Client';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  // Check if user can access admin routes
  static bool canAccessAdminRoutes(User user) {
    return isAdmin(user);
  }

  // Check if user can access specific admin features
  static bool canManageUsers(User user) {
    return isSuperAdmin(user);
  }

  static bool canManageProducts(User user) {
    return isAdmin(user);
  }

  static bool canManageOrders(User user) {
    return isAdmin(user);
  }

  static bool canViewAnalytics(User user) {
    return isAdmin(user);
  }

  static bool canManageSupport(User user) {
    return isAdmin(user);
  }
}
