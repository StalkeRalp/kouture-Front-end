import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';
import 'package:logger/logger.dart';

class AuthService {
  final _client = Supabase.instance.client;
  final _logger = Logger();

  /// S'inscrire avec email/password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'client',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );
      _logger.i('Inscription réussie pour $email');
      return response;
    } catch (e) {
      _logger.e('Erreur d\'inscription: $e');
      rethrow;
    }
  }

  /// Connexion
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _logger.i('Connexion réussie pour $email');
      return response;
    } catch (e) {
      _logger.e('Erreur de connexion: $e');
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Récupérer le profil utilisateur actuel
  Future<UserProfileModel?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();
      
      return UserProfileModel.fromJson(response);
    } catch (e) {
      _logger.e('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }

  /// Mettre à jour le profil
  Future<void> updateProfile(UserProfileModel profile) async {
    try {
      await _client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
      _logger.i('Profil mis à jour pour ${profile.id}');
    } catch (e) {
      _logger.e('Erreur lors de la mise à jour du profil: $e');
      rethrow;
    }
  }

  /// Stream du statut d'authentification
  Stream<AuthState> get authStateChanges =\u003e _client.auth.onAuthStateChange;
  
  User? get currentUser =\u003e _client.auth.currentUser;
}
