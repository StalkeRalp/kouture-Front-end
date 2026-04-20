import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/order_service.dart';

final getIt = GetIt.instance;

class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    // 1. Initialiser Supabase
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );

    // 2. Enregistrer les services avec GetIt (Singletons)
    getIt.registerLazySingleton<AuthService>(() => AuthService());
    getIt.registerLazySingleton<ProductService>(() => ProductService());
    getIt.registerLazySingleton<OrderService>(() => OrderService());
  }

  static SupabaseClient get client =\u003e Supabase.instance.client;
}
