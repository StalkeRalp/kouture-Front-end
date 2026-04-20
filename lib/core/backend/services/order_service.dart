import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import 'package:logger/logger.dart';

class OrderService {
  final _client = Supabase.instance.client;
  final _logger = Logger();

  /// Récupérer l'historique des commandes de l'utilisateur connecté
  Future<List<OrderModel>> getMyOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('client_id', user.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response)
          .map((o) => OrderModel.fromJson(o))
          .toList();
    } catch (e) {
      _logger.e('Erreur getMyOrders: $e');
      return [];
    }
  }

  /// Créer une commande complète avec ses articles
  Future<void> createOrder({
    required double totalAmount,
    required String tailorId,
    required String shippingAddress,
    required List<Map<String, dynamic>> cartItems,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      // 1. Créer la commande (Header)
      await _client.from('orders').insert({
        'id': orderId,
        'client_id': user.id,
        'tailor_id': tailorId,
        'price': totalAmount,
        'status': 'pending',
        'delivery_address': shippingAddress,
      });

      // 2. Créer les lignes de commande
      final items = cartItems.map((item) => {
        'order_id': orderId,
        'product_id': item['product_id'],
        'product_name_at_purchase': item['product_name'],
        'price_at_purchase': item['price'],
        'quantity': item['quantity'],
        'size': item['size'],
        'color': item['color'],
      }).toList();

      await _client.from('order_items').insert(items);
      
      _logger.i('Commande $orderId créée avec succès');
    } catch (e) {
      _logger.e('Erreur création commande: $e');
      rethrow;
    }
  }

  /// Gestion du panier persistant
  Future<List<Map<String, dynamic>>> getCart() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    
    final response = await _client.from('cart_items').select('*, products(*)').eq('user_id', user.id);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addToCart(String productId, {String? size, String? color, int quantity = 1}) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('cart_items').insert({
      'user_id': user.id,
      'product_id': productId,
      'size': size,
      'color': color,
      'quantity': quantity,
    });
  }
}
