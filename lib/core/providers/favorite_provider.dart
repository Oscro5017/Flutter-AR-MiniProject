import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/furniture_model.dart';
import '../../data/dummy_furniture.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Furniture> _favorites = [];
  static const String _storageKey = 'favorite_items_names';

  List<Furniture> get favorites => _favorites;

  FavoriteProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_storageKey);
    if (names != null) {
      _favorites.clear();
      for (var name in names) {
        try {
          final item = furnitureList.firstWhere((f) => f.name == name);
          _favorites.add(item);
        } catch (_) {}
      }
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final names = _favorites.map((e) => e.name).toList();
    await prefs.setStringList(_storageKey, names);
  }

  bool isFavorite(Furniture furniture) {
    return _favorites.any((item) => item.name == furniture.name);
  }

  void toggleFavorite(Furniture furniture) {
    final index = _favorites.indexWhere((item) => item.name == furniture.name);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(furniture);
    }
    _saveToPrefs();
    notifyListeners();
  }
}
