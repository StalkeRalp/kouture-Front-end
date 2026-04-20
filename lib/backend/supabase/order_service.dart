import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final _client = Supabase.instance.client;

  /// Récupère les articles du panier d'un utilisateur
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', user.id);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Ajoute un produit au panier
  Future<void> addToCart({
    required String productId,
    required String size,
    required String color,
    int quantity = 1,
  }) async {
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

  /// Passe une commande à partir du panier
  Future<void> checkout({
    required String orderId,
    required String tailorId,
    required double totalAmount,
    required String shippingAddress,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // 1. Créer la commande
    await _client.from('orders').insert({
      'id': orderId,
      'client_id': user.id,
      'tailor_id': tailorId,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'status': 'pending',
    });

    // 2. Créer les articles de la commande
    final orderItems = items.map((item) => {
      'order_id': orderId,
      'product_id': item['productId'],
      'product_name_at_purchase': item['product']['name'],
      'price_at_purchase': item['product']['price'],
      'quantity': item['quantity'],
      'size': item['size'],
      'color': item['color'],
    }).toList();

    await _client.from('order_items').insert(orderItems);

    // 3. Vider le panier
    await _client.from('cart_items').delete().eq('user_id', user.id);
  }

  /// Liste des commandes d'un utilisateur
  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
}
