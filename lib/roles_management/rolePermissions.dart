const Map<String, List<String>> rolePermissions = {
  '/dailyProduction': ['admin', 'manager', 'staff', 'operator', 'milkman'],
  '/milkSales': ['admin', 'manager', 'sales'],
  '/cattleForm': ['admin', 'manager', 'staff'],
  '/cattleListPage': ['admin', 'manager', 'staff'],
  '/adminWages': ['admin', 'manager'],
  '/machinery': ['admin', 'manager', 'maintenance'],
  '/feeds': ['admin', 'manager', 'staff'],
  '/inventory': ['admin', 'manager', 'staff'],
  '/medicine': ['admin', 'manager', 'veterinarian'],
  //'/notification': ['admin', 'manager', 'staff'],
  '/workerList': ['admin', 'manager'],
  '/reports': ['admin', 'manager', 'analyst'],
  //'/workerProfile': ['admin', 'manager', 'hr'],
};

bool canAccessPage(String userRole, String route) {
  final allowedRoles = rolePermissions[route] ?? [];
  return allowedRoles.contains(userRole);
}
