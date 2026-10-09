import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/furniture_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/favorite_provider.dart';
import 'core/providers/compare_provider.dart';
import 'core/providers/budget_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(preferences)),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FurnitureProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => CompareProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: const ARInteriorApp(),
    ),
  );
}
