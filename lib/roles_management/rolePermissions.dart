const Map<String, List<String>> rolePermissions = {
  '/milkSales': ['admin', 'manager', 'sales'],
  '/dailyProduction': ['admin', 'manager', 'staff', 'operator','milkman'],
  '/cattleListPage': ['admin', 'manager', 'staff'],
  '/reports': ['admin', 'manager', 'analyst'],
  '/adminWages': ['admin', 'manager'],
  '/machinery': ['admin', 'manager', 'maintenance'],
  '/feeds': ['admin', 'manager', 'staff'],
  '/inventory': ['admin', 'manager', 'staff'],
  '/medicine': ['admin', 'manager', 'veterinarian'],
  //'/notification': ['admin', 'manager', 'staff'],
  '/workerList': ['admin', 'manager'],
  //'/workerProfile': ['admin', 'manager', 'hr'],
  
  '/cattleForm': ['admin', 'manager', 'staff'],
};

bool canAccessPage(String userRole, String route) {
  final allowedRoles = rolePermissions[route] ?? [];
  return allowedRoles.contains(userRole);
}
