import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final _client = Supabase.instance.client;

  /// Récupère toutes les catégories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client.from('categories').select('*').order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Récupère les produits vedettes avec leur image principale
  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    final response = await _client
        .from('products')
        .select('*')
        .eq('is_featured', true)
        .limit(10);
    return _mapProducts(response);
  }

  /// Récupère les produits par catégorie
  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryId) async {
    final response = await _client
        .from('products')
        .select('*')
        .eq('category_id', categoryId);
    return _mapProducts(response);
  }

  /// Récupère un produit par son ID (détails complets)
  Future<Map<String, dynamic>?> getProductById(String id) async {
    final response = await _client
        .from('products')
        .select('*, profiles!tailor_id(*)')
        .eq('id', id)
        .single();
    
    if (response == null) return null;
    
    return {
      ...response,
      'images': response['image_urls'] ?? [],
      'vendor': response['profiles'],
    };
  }

  /// Recherche de produits
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final response = await _client
        .from('products')
        .select('*')
        .or('name.ilike.%$query%,description.ilike.%$query%');
    return _mapProducts(response);
  }

  /// Helper pour aligner la structure des images
  List<Map<String, dynamic>> _mapProducts(dynamic response) {
    if (response == null) return [];
    return List<Map<String, dynamic>>.from(response).map((p) {
      return {
        ...p,
        'images': p['image_urls'] ?? [],
      };
    }).toList();
  }
}
