import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MockFirebase extends ChangeNotifier {
  static final MockFirebase _instance = MockFirebase._internal();
  factory MockFirebase() => _instance;
  MockFirebase._internal();

  List<dynamic> _products = [];
  List<dynamic> _categoriesData = [];
  List<dynamic> _vendors = [];
  List<dynamic> _reviews = [];
  List<dynamic> _users = [];
  List<dynamic> _promotions = [];
  List<dynamic> _notifications = [];
  List<Map<String, dynamic>> _cartItems = [];
  bool _isInitialized = false;

  List<String> favoriteIds = [];
  List<String> recentSearches = [];

  List<dynamic> get allProducts => _products;
  List<dynamic> get promotions => _promotions;

  /// Call this inside main() or at the start of your app
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load products, reviews, categories, vendors
      final dbStr = await rootBundle.loadString('lib/backend/products.json');
      final dbData = jsonDecode(dbStr);

      if (dbData is Map) {
        _products = List<dynamic>.from(dbData['products'] ?? []);
        _categoriesData = List<dynamic>.from(dbData['categories'] ?? []);
        _vendors = List<dynamic>.from(dbData['vendors'] ?? []);
        _reviews = List<dynamic>.from(dbData['reviews'] ?? []);
        _notifications = List<dynamic>.from(dbData['notifications'] ?? []);
        _users = List<dynamic>.from(dbData['users'] ?? []);
        _promotions = List<dynamic>.from(dbData['promotions'] ?? []);
      }
      
      // Load users & promotions from users.json
      try {
        final usersStr = await rootBundle.loadString('lib/backend/users.json');
        final uData = jsonDecode(usersStr);
        if (uData is Map) {
          _users = List<dynamic>.from(uData['users'] ?? []);
          _promotions = List<dynamic>.from(uData['promotions'] ?? []);
        }
      } catch (e) {
        // ignore if missing or malformed
      }

      try {
        final u1 = _users.firstWhere((u) => u['id'] == 'u1');
        favoriteIds = List<String>.from(u1['favorites'] ?? []);
      } catch (e) {
        favoriteIds = [];
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('MockFirebase Initialization Error: $e');
    }
  }

  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  // --- PRODUCTS ---
  
  Future<List<dynamic>> getProducts() async {
    await _delay();
    return List.from(_products);
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    await _delay();
    // Simulate ID generation
    product['id'] = 'p_${DateTime.now().millisecondsSinceEpoch}';
    _products.add(product);
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    await _delay();
    try {
      final p = _products.firstWhere((p) => p['id'].toString() == id);
      return Map<String, dynamic>.from(p);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getVendorById(String id) async {
    await _delay();
    try {
      final v = _vendors.firstWhere((v) => v['id'].toString() == id);
      return Map<String, dynamic>.from(v);
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getReviewsByProductId(String productId) async {
    await _delay();
    return _reviews.where((r) => r['productId'].toString() == productId).toList();
  }

  Future<void> addReview(Map<String, dynamic> review) async {
    await _delay();
    review['id'] = 'r${DateTime.now().millisecondsSinceEpoch}';
    review['date'] = DateTime.now().toString().split(' ')[0];
    review['likes'] = 0;
    _reviews.insert(0, review);
    notifyListeners();
  }

  // --- NOTIFICATIONS ---

  int get unreadNotificationsCount => _notifications.where((n) => n['userId'] == 'u1' && !(n['isRead'] ?? false)).length;

  Future<List<dynamic>> getNotifications() async {
    await _delay();
    return _notifications.where((n) => n['userId'] == 'u1').toList();
  }

  Future<void> markNotificationAsRead(String id) async {
    await _delay();
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i]['id'] == id) {
        _notifications[i]['isRead'] = true;
        notifyListeners();
        break;
      }
    }
  }

  Future<void> markAllAsRead() async {
    await _delay();
    for (var n in _notifications) {
      if (n['userId'] == 'u1') n['isRead'] = true;
    }
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    await _delay();
    _notifications.removeWhere((n) => n['userId'] == 'u1');
    notifyListeners();
  }

  Future<bool> sendTestNotification({
    required String type,
    required String title,
    required String message,
  }) async {
    await _delay();
    final user = currentUser;
    if (user == null) return false;

    final prefs = user['preferences'] ?? {};
    
    // Check if push is enabled generally
    if (!(prefs['push_notifications'] ?? true)) {
      debugPrint('Notification skipped: Push disabled');
      return false;
    }

    // Check specific categories if needed
    if (type == 'promo' && !(prefs['promotions'] ?? true)) {
      debugPrint('Notification skipped: Promotions disabled');
      return false;
    }

    final newNotif = {
      'id': 'n${DateTime.now().millisecondsSinceEpoch}',
      'userId': 'u1',
      'type': type,
      'title': title,
      'message': message,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _notifications.insert(0, newNotif);
    notifyListeners();
    return true;
  }

  // --- AUTH / USER ---
  Map<String, dynamic>? get currentUser => _users.cast<Map<String, dynamic>?>().firstWhere(
    (u) => u?['id'] == 'u1', 
    orElse: () => null
  );

  Future<Map<String, dynamic>?> getUser(String id) async {
    await _delay();
    try {
      return _users.firstWhere((u) => u['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _delay();
    for (int i = 0; i < _users.length; i++) {
      if (_users[i]['id'] == id) {
        final updatedUser = Map<String, dynamic>.from(_users[i]);
        data.forEach((key, value) {
          updatedUser[key] = value;
        });
        _users[i] = updatedUser;
        
        // Save to disk for local persistence
        _saveToDisk();
        
        notifyListeners(); // Notify UI to rebuild
        break;
      }
    }
  }

  void _saveToDisk() {
    try {
      // Use relative path which is safer for local dev
      final file = File('lib/backend/users.json');
      final data = {
        'users': _users,
        'promotions': _promotions,
      };
      file.writeAsStringSync(jsonEncode(data));
    } catch (e) {
      // Silently fail persistence for local sessions
    }
  }

  // --- FAVORITES ---
  
  bool isFavorite(String id) => favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    notifyListeners();
    // Simulate updating the user in db
    updateUser('u1', {'favorites': favoriteIds});
  }

  // --- SEARCH ---

  void addSearchQuery(String query) {
    if (query.trim().isEmpty) return;
    recentSearches.remove(query); // Remove if exists to put at the top
    recentSearches.insert(0, query);
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }
    notifyListeners();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    notifyListeners();
  }

  void removeRecentSearch(String query) {
    recentSearches.remove(query);
    notifyListeners();
  }

  Future<List<dynamic>> searchProducts(String query) async {
    await _delay();
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _products.where((p) {
      final name = p['name'].toString().toLowerCase();
      final tags = (p['tags'] as List?)?.map((t) => t.toString().toLowerCase()).toList() ?? [];
      return name.contains(q) || tags.any((t) => t.contains(q));
    }).toList();
  }

  // --- CART ---

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(Map<String, dynamic> product, {String? size, String? color, int quantity = 1}) {
    // Check if item already in cart with same size/color
    final existingIndex = _cartItems.indexWhere((item) => 
      item['productId'] == product['id'] && 
      item['size'] == size && 
      item['color'] == color
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex]['quantity'] += quantity;
    } else {
      _cartItems.add({
        'id': 'cart_${DateTime.now().millisecondsSinceEpoch}',
        'productId': product['id'],
        'product': product, // Store minimal product info
        'quantity': quantity,
        'size': size ?? (product['sizes'] != null && (product['sizes'] as List).isNotEmpty ? product['sizes'][0] : 'unique'),
        'color': color ?? (product['colors'] != null && (product['colors'] as List).isNotEmpty ? product['colors'][0] : null),
      });
    }
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item['id'] == cartItemId);
    notifyListeners();
  }

  void updateCartQuantity(String cartItemId, int delta) {
    final index = _cartItems.indexWhere((item) => item['id'] == cartItemId);
    if (index != -1) {
      final newQty = _cartItems[index]['quantity'] + delta;
      if (newQty > 0) {
        _cartItems[index]['quantity'] = newQty;
        notifyListeners();
      } else {
        removeFromCart(cartItemId);
      }
    }
  }

  double get cartSubtotal {
    double total = 0;
    for (var item in _cartItems) {
      final price = (item['product']['price'] as num).toDouble();
      total += price * item['quantity'];
    }
    return total;
  }

  double get cartShipping => _cartItems.isEmpty ? 0 : 2500.0; // Fixed shipping for mock
  double get cartTotal => cartSubtotal + cartShipping;

  // --- FILTER METADATA ---

  Future<List<String>> getCategoriesList() async {
    // If we have categoriesData from JSON, use it, otherwise extract from products
    if (_categoriesData.isNotEmpty) {
      return _categoriesData.map((c) => c['name'].toString()).toList();
    }
    return _products.map((p) => p['category'].toString()).toSet().toList();
  }

  Future<List<String>> getUniqueSizes() async {
    final sizes = <String>{};
    for (var p in _products) {
      final pSizes = p['sizes'] as List?;
      if (pSizes != null) {
        for (var s in pSizes) {
          sizes.add(s.toString());
        }
      }
    }
    // Simple sort for sizes if they look like standard ones
    final list = sizes.toList()..sort();
    return list;
  }

  Future<List<String>> getUniqueColors() async {
    final colors = <String>{};
    for (var p in _products) {
      final pColors = p['colors'] as List?;
      if (pColors != null) {
        for (var c in pColors) {
          colors.add(c.toString());
        }
      }
    }
    return colors.toList();
  }

  // --- ORDERS ---
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get allOrders => _orders;

  Future<void> createOrder(List<Map<String, dynamic>> items, double total) async {
    await _delay();
    final newOrder = {
      'id': 'KT-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      'userId': 'u1',
      'items': List.from(items),
      'total': total,
      'status': 'En attente', // Initial status
      'date': DateTime.now().toIso8601String(),
      'shippingAddress': 'Bastos, Rue 1234, Yaoundé, CMR',
      'paymentMethod': 'Orange Money', // Mock default
    };
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getOrderById(String id) async {
    await _delay();
    try {
      return _orders.firstWhere((o) => o['id'] == id);
    } catch (e) {
      return null;
    }
  }

  void updateOrderStatus(String orderId, String newStatus) {
    for (int i = 0; i < _orders.length; i++) {
      if (_orders[i]['id'] == orderId) {
        _orders[i]['status'] = newStatus;
        notifyListeners();
        break;
      }
    }
  }

  // --- CHAT ---
  final Map<String, List<Map<String, dynamic>>> _chatMessages = {
    'chat1': [
      {'senderId': 'v1', 'text': 'Bonjour! Comment puis-je vous aider aujourd\'hui?', 'time': '10:00'},
      {'senderId': 'u1', 'text': 'Bonjour, je voudrais savoir si cet ensemble est disponible en XXL.', 'time': '10:05'},
    ],
  };

  List<Map<String, dynamic>> getChatMessages(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  Future<void> sendMessage(String chatId, String text) async {
    await _delay();
    if (!_chatMessages.containsKey(chatId)) {
      _chatMessages[chatId] = [];
    }
    _chatMessages[chatId]!.add({
      'senderId': 'u1',
      'text': text,
      'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    });
    notifyListeners();
  }

  Future<List<dynamic>> getProductsByVendor(String vendorId) async {
    await _delay();
    return _products.where((p) => p['vendorId'] == vendorId).toList();
  }
}
