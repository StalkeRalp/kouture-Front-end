import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import 'package:logger/logger.dart';

class ProductService {
  final _client = Supabase.instance.client;
  final _logger = Logger();

  /// Récupérer toutes les catégories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client.from('categories').select('*').order('name');
      return List<Map<String, dynamic>>.from(response)
          .map((c) => CategoryModel.fromJson(c))
          .toList();
    } catch (e) {
      _logger.e('Erreur getCategories: $e');
      return [];
    }
  }

  /// Récupérer les produits vedettes
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .eq('is_featured', true)
          .limit(20);
      return List<Map<String, dynamic>>.from(response)
          .map((p) => ProductModel.fromJson(p))
          .toList();
    } catch (e) {
      _logger.e('Erreur getFeaturedProducts: $e');
      return [];
    }
  }

  /// Récupérer les produits par catégorie
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .eq('category_id', categoryId);
      return List<Map<String, dynamic>>.from(response)
          .map((p) => ProductModel.fromJson(p))
          .toList();
    } catch (e) {
      _logger.e('Erreur getProductsByCategory: $e');
      return [];
    }
  }

  /// Récupérer un produit complet avec les infos du couturier
  Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await _client
          .from('products')
          .select('*, profiles!tailor_id(*)')
          .eq('id', id)
          .single();
      
      return ProductModel.fromJson(response);
    } catch (e) {
      _logger.e('Erreur getProductById: $e');
      return null;
    }
  }

  /// Recherche globale de produits
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select('*')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .limit(50);
      return List<Map<String, dynamic>>.from(response)
          .map((p) => ProductModel.fromJson(p))
          .toList();
    } catch (e) {
      _logger.e('Erreur searchProducts: $e');
      return [];
    }
  }
}
