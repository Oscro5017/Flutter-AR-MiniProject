import 'package:go_router/go_router.dart';
import '../models/furniture_model.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/catalog/catalog_screen.dart';
import '../screens/detail/furniture_detail_screen.dart';
import '../screens/scan/scan_room_screen.dart';
import '../screens/ar/placement_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/favorite/favorite_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/compare/compare_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/add_edit_furniture_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/receipt/receipt_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        path: "/",
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: "/login",
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: "/home",
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: "/catalog",
        builder: (_, __) => const CatalogScreen(),
      ),
      GoRoute(
        path: "/detail",
        builder: (context, state) {
          final furniture = state.extra as Furniture;
          return FurnitureDetailScreen(furniture: furniture);
        },
      ),
      GoRoute(
        path: "/scan",
        builder: (_, __) => const ScanRoomScreen(),
      ),
      GoRoute(
        path: "/placement",
        builder: (context, state) {
          final furniture = state.extra as Furniture?;
          return PlacementScreen(initialFurniture: furniture);
        },
      ),
      GoRoute(
        path: "/profile",
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: "/settings",
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: "/favorite",
        builder: (_, __) => const FavoriteScreen(),
      ),
      GoRoute(
        path: "/cart",
        builder: (_, __) => const CartScreen(),
      ),
      GoRoute(
        path: "/compare",
        builder: (_, __) => const CompareScreen(),
      ),
      GoRoute(
        path: "/admin",
        builder: (_, __) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: "/admin/add-edit",
        builder: (context, state) {
          final furniture = state.extra as Furniture?;
          return AddEditFurnitureScreen(furniture: furniture);
        },
      ),
      GoRoute(
        path: "/checkout",
        builder: (_, __) => const CheckoutScreen(),
      ),
      GoRoute(
        path: "/receipt",
        builder: (context, state) {
          final orderData = state.extra as Map<String, dynamic>;
          return ReceiptScreen(orderData: orderData);
        },
      ),
    ],
  );
}
