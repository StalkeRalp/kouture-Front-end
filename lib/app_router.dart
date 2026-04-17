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
import 'screens/favorites/favoritesTailor_screen.dart';
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
import 'screens/order/order_detail_screen.dart';
import 'screens/order/order_analytics_screen.dart';
import 'screens/tracking/tracking_screen.dart';
import 'screens/address/address_list_screen.dart';
import 'screens/address/add_address_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/notifications/notification_settings_screen.dart';
import 'screens/activities/activities_screen.dart';
import 'screens/chat/chat_detail_screen.dart';
import 'screens/vendor/vendor_profile_screen.dart';
import 'screens/vendor/vendor_products_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/offline/offline_screen.dart';
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

  static const String initial = SplashScreen.routeName;

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
    SplashScreen.routeName:              (context, args) => const SplashScreen(),
    OnboardingScreen.routeName:          (context, args) => const OnboardingScreen(),
    LoginScreen.routeName:               (context, args) => const LoginScreen(),
    RegisterScreen.routeName:            (context, args) => const RegisterScreen(),
    ForgotPasswordScreen.routeName:      (context, args) => const ForgotPasswordScreen(),
    OtpVerificationScreen.routeName:     (context, args) => const OtpVerificationScreen(),
    HomeScreen.routeName:                (context, args) => const HomeScreen(),
    DiscoverScreen.routeName:            (context, args) => const DiscoverScreen(),
    CategoryScreen.routeName:            (context, args) => const CategoryScreen(),
    CategoryDetailScreen.routeName:      (context, args) => const CategoryDetailScreen(),
    SearchScreen.routeName:              (context, args) => const SearchScreen(),
    SearchResultsScreen.routeName:       (context, args) => const SearchResultsScreen(),
    FilterScreen.routeName:              (context, args) => const FilterScreen(),
    ProductDetailScreen.routeName:       (context, args) => ProductDetailScreen(product: args as Map<String, dynamic>),
    ProductImagesScreen.routeName:       (context, args) => const ProductImagesScreen(),
    ProductInfoScreen.routeName:         (context, args) => ProductInfoScreen(product: args as Map<String, dynamic>),
    ReviewsScreen.routeName:             (context, args) => ReviewsScreen(product: args as Map<String, dynamic>),
    AddReviewScreen.routeName:           (context, args) => AddReviewScreen(product: args as Map<String, dynamic>),
    FavoritesScreen.routeName:           (context, args) => const FavoritesScreen(),
    FavoritesTailorScreen.routeName:     (context, args) => const FavoritesTailorScreen(),
    CartScreen.routeName:                (context, args) => const CartScreen(),
    CartSummaryScreen.routeName:         (context, args) => const CartSummaryScreen(),
    PaymentMethodScreen.routeName:       (context, args) => const PaymentMethodScreen(),
    OrangeMoneyScreen.routeName:         (context, args) => const OrangeMoneyScreen(),
    MobileMoneyScreen.routeName:         (context, args) => const MobileMoneyScreen(),
    CardPaymentScreen.routeName:         (context, args) => const CardPaymentScreen(),
    PaymentProcessingScreen.routeName:   (context, args) => const PaymentProcessingScreen(),
    PaymentSuccessScreen.routeName:      (context, args) => const PaymentSuccessScreen(),
    PaymentFailureScreen.routeName:      (context, args) => const PaymentFailureScreen(),
    CheckoutScreen.routeName:            (context, args) => const CheckoutScreen(),
    OrderConfirmationScreen.routeName:   (context, args) => const OrderConfirmationScreen(),
    ActivitiesScreen.routeName:          (context, args) => ActivitiesScreen(initialTabIndex: args as int? ?? 0),
    OrderDetailScreen.routeName:         (context, args) => const OrderDetailScreen(),
    OrderAnalyticsScreen.routeName:      (context, args) => const OrderAnalyticsScreen(),
    EditProfileScreen.routeName:         (context, args) => const EditProfileScreen(),
    ProfileScreen.routeName:             (context, args) => const ProfileScreen(),
    SettingsScreen.routeName:            (context, args) => const SettingsScreen(),
    LanguageScreen.routeName:            (context, args) => const LanguageScreen(),
    PrivacyScreen.routeName:             (context, args) => const PrivacyScreen(),
    HelpScreen.routeName:                (context, args) => const HelpScreen(),
    AboutScreen.routeName:               (context, args) => const AboutScreen(),
    CountryScreen.routeName:             (context, args) => const CountryScreen(),
    CurrencyScreen.routeName:            (context, args) => const CurrencyScreen(),
    MeasurementsScreen.routeName:        (context, args) => const MeasurementsScreen(),
    AddressListScreen.routeName:         (context, args) => const AddressListScreen(),
    AddAddressScreen.routeName:          (context, args) => const AddAddressScreen(),
    NotificationsScreen.routeName:       (context, args) => const NotificationsScreen(),
    NotificationSettingsScreen.routeName: (context, args) => const NotificationSettingsScreen(),
    ChatDetailScreen.routeName:          (context, args) => const ChatDetailScreen(),
    VendorProfileScreen.routeName:       (context, args) => const VendorProfileScreen(),
    VendorProductsScreen.routeName:      (context, args) => const VendorProductsScreen(),
    TrackingScreen.routeName:            (context, args) => const TrackingScreen(),
    MainNavigationScreen.routeName:      (context, args) => MainNavigationScreen(initialIndex: args as int? ?? 0),
    OfflineScreen.routeName:             (context, args) => const OfflineScreen(),
  };
}
