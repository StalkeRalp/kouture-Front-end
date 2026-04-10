import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_verification_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/discover/discover_screen.dart';
import 'screens/category/category_screen.dart';
import 'screens/category/category_detail_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/search/search_results_screen.dart';
import 'screens/search/filter_screen.dart';
import 'screens/product_detail/product_detail_screen.dart';
import 'screens/product_detail/product_info_screen.dart';
import 'screens/product_detail/product_images_screen.dart';
import 'screens/reviews/reviews_screen.dart';
import 'screens/reviews/add_review_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/cart/cart_summary_screen.dart';
import 'screens/payment/payment_method_screen.dart';
import 'screens/payment/orange_money_screen.dart';
import 'screens/payment/mobile_money_screen.dart';
import 'screens/payment/card_payment_screen.dart';
import 'screens/payment/payment_processing_screen.dart';
import 'screens/payment/payment_success_screen.dart';
import 'screens/payment/payment_failure_screen.dart';
import 'screens/order/checkout_screen.dart';
import 'screens/order/order_confirmation_screen.dart';
import 'screens/order/orders_list_screen.dart';
import 'screens/order/order_detail_screen.dart';
import 'screens/order/order_analytics_screen.dart';
import 'screens/tracking/tracking_screen.dart';
import 'screens/address/address_list_screen.dart';
import 'screens/address/add_address_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/notifications/notification_settings_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/chat_detail_screen.dart';
import 'screens/vendor/vendor_profile_screen.dart';
import 'screens/vendor/vendor_products_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/language_screen.dart';
import 'screens/settings/privacy_screen.dart';
import 'screens/settings/help_screen.dart';
import 'screens/settings/about_screen.dart';
import 'screens/settings/country_screen.dart';
import 'screens/settings/currency_screen.dart';
import 'screens/settings/measurements_screen.dart';

/// AppRouter — Principe OCP : ouvert à l'extension, fermé à la modification.
/// Pour ajouter une route, il suffit d'ajouter une entrée dans la map.
class AppRouter {
  AppRouter._();

  static const String initial = MainNavigationScreen.routeName; // Bypass splash for dev

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = _routes[settings.name];

    if (builder != null) {
      return MaterialPageRoute(
        builder: (ctx) => builder(ctx, settings.arguments),
        settings: settings,
      );
    }

    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('404 — Page introuvable')),
      ),
    );
  }

  static final Map<
    String,
    Widget Function(BuildContext, Object?)
  > _routes = {
    SplashScreen.routeName:              (_, __) => const SplashScreen(),
    OnboardingScreen.routeName:          (_, __) => const OnboardingScreen(),
    LoginScreen.routeName:               (_, __) => const LoginScreen(),
    RegisterScreen.routeName:            (_, __) => const RegisterScreen(),
    ForgotPasswordScreen.routeName:      (_, __) => const ForgotPasswordScreen(),
    OtpVerificationScreen.routeName:     (_, __) => const OtpVerificationScreen(),
    HomeScreen.routeName:                (_, __) => const HomeScreen(),
    DiscoverScreen.routeName:            (_, __) => const DiscoverScreen(),
    CategoryScreen.routeName:            (_, __) => const CategoryScreen(),
    CategoryDetailScreen.routeName:      (_, __) => const CategoryDetailScreen(),
    SearchScreen.routeName:              (_, __) => const SearchScreen(),
    SearchResultsScreen.routeName:       (_, __) => const SearchResultsScreen(),
    FilterScreen.routeName:              (_, __) => const FilterScreen(),
    ProductDetailScreen.routeName:       (_, args) => ProductDetailScreen(product: args as Map<String, dynamic>),
    ProductImagesScreen.routeName:       (_, __) => const ProductImagesScreen(),
    ReviewsScreen.routeName:             (_, args) => ReviewsScreen(product: args as Map<String, dynamic>),
    AddReviewScreen.routeName:           (_, args) => AddReviewScreen(product: args as Map<String, dynamic>),
    FavoritesScreen.routeName:           (_, __) => const FavoritesScreen(),
    CartScreen.routeName:                (_, __) => const CartScreen(),
    CartSummaryScreen.routeName:         (_, __) => const CartSummaryScreen(),
    PaymentMethodScreen.routeName:       (_, __) => const PaymentMethodScreen(),
    OrangeMoneyScreen.routeName:         (_, __) => const OrangeMoneyScreen(),
    MobileMoneyScreen.routeName:         (_, __) => const MobileMoneyScreen(),
    CardPaymentScreen.routeName:         (_, __) => const CardPaymentScreen(),
    PaymentProcessingScreen.routeName:   (_, __) => const PaymentProcessingScreen(),
    PaymentSuccessScreen.routeName:      (_, __) => const PaymentSuccessScreen(),
    PaymentFailureScreen.routeName:      (_, __) => const PaymentFailureScreen(),
    CheckoutScreen.routeName:            (_, __) => const CheckoutScreen(),
    OrderConfirmationScreen.routeName:   (_, __) => const OrderConfirmationScreen(),
    OrdersListScreen.routeName:          (_, __) => const OrdersListScreen(),
    OrderDetailScreen.routeName:         (_, __) => const OrderDetailScreen(),
    OrderAnalyticsScreen.routeName:      (_, __) => const OrderAnalyticsScreen(),
    TrackingScreen.routeName:            (_, __) => const TrackingScreen(),
    AddressListScreen.routeName:         (_, __) => const AddressListScreen(),
    AddAddressScreen.routeName:          (_, __) => const AddAddressScreen(),
    NotificationsScreen.routeName:       (_, __) => const NotificationsScreen(),
    NotificationSettingsScreen.routeName:(_, __) => const NotificationSettingsScreen(),
    ChatListScreen.routeName:            (_, __) => const ChatListScreen(),
    ChatDetailScreen.routeName:          (_, __) => const ChatDetailScreen(),
    VendorProfileScreen.routeName:       (_, __) => const VendorProfileScreen(),
    VendorProductsScreen.routeName:      (_, __) => const VendorProductsScreen(),
    ProfileScreen.routeName:             (_, __) => const ProfileScreen(),
    MainNavigationScreen.routeName:      (_, __) => const MainNavigationScreen(),
    ProductInfoScreen.routeName:         (_, args) => ProductInfoScreen(product: args as Map<String, dynamic>),
    EditProfileScreen.routeName:         (_, __) => const EditProfileScreen(),
    SettingsScreen.routeName:            (_, __) => const SettingsScreen(),
    LanguageScreen.routeName:            (_, __) => const LanguageScreen(),
    PrivacyScreen.routeName:             (_, __) => const PrivacyScreen(),
    HelpScreen.routeName:                (_, __) => const HelpScreen(),
    AboutScreen.routeName:               (_, __) => const AboutScreen(),
    CountryScreen.routeName:             (_, __) => const CountryScreen(),
    CurrencyScreen.routeName:            (_, __) => const CurrencyScreen(),
    MeasurementsScreen.routeName:        (_, __) => const MeasurementsScreen(),
  };
}
