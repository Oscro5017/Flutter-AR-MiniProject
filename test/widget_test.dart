// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/app.dart';
import '../lib/core/theme/theme_provider.dart';
import '../lib/core/providers/cart_provider.dart';
import '../lib/core/providers/favorite_provider.dart';
import '../lib/core/providers/compare_provider.dart';
import '../lib/core/providers/user_provider.dart';
import '../lib/core/providers/furniture_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(preferences)),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => FurnitureProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => FavoriteProvider()),
          ChangeNotifierProvider(create: (_) => CompareProvider()),
        ],
        child: const ARInteriorApp(),
      ),
    );

    expect(find.byType(ARInteriorApp), findsOneWidget);
  });
}
