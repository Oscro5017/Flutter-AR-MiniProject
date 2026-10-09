import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/furniture_model.dart';
import '../../data/dummy_furniture.dart';

class CartProvider extends ChangeNotifier {
  Map<String, int> _items = {};
  final Set<String> _selectedItemNames = {};
  static const String _storageKey = 'cart_items';

  List<String> get itemNames => _items.keys.toList();

  int get itemCount => _items.values.fold(0, (sum, quantity) => sum + quantity);

  Set<String> get selectedItemNames => Set.unmodifiable(_selectedItemNames);

  int get selectedItemCount {
    int total = 0;
    _items.forEach((name, qty) {
      if (_selectedItemNames.contains(name)) {
        total += qty;
      }
    });
    return total;
  }

  bool isItemSelected(String name) => _selectedItemNames.contains(name);

  bool get isAllSelected => _items.isNotEmpty && _selectedItemNames.length == _items.length;

  CartProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      try {
        final decoded = json.decode(data) as Map<String, dynamic>;
        _items = decoded.map((key, value) => MapEntry(key, value as int));
        _selectedItemNames.addAll(_items.keys);
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading cart: $e");
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(_items));
  }

  int getQuantity(String name) => _items[name] ?? 0;

  double get totalPrice {
    double total = 0;
    _items.forEach((name, qty) {
      try {
        final furniture = furnitureList.firstWhere((f) => f.name == name);
        total += furniture.price * qty;
      } catch (_) {}
    });
    return total;
  }

  double get selectedTotalPrice {
    double total = 0;
    _items.forEach((name, qty) {
      if (_selectedItemNames.contains(name)) {
        try {
          final furniture = furnitureList.firstWhere((f) => f.name == name);
          total += furniture.price * qty;
        } catch (_) {}
      }
    });
    return total;
  }

  void toggleItemSelection(String name) {
    if (_selectedItemNames.contains(name)) {
      _selectedItemNames.remove(name);
    } else {
      _selectedItemNames.add(name);
    }
    notifyListeners();
  }

  void selectAll(bool select) {
    if (select) {
      _selectedItemNames.addAll(_items.keys);
    } else {
      _selectedItemNames.clear();
    }
    notifyListeners();
  }

  void addToCart(Furniture furniture) {
    if (_items.containsKey(furniture.name)) {
      _items[furniture.name] = _items[furniture.name]! + 1;
    } else {
      _items[furniture.name] = 1;
    }
    _selectedItemNames.add(furniture.name);
    _saveToPrefs();
    notifyListeners();
  }

  void removeFromCart(String name) {
    if (_items.containsKey(name)) {
      if (_items[name]! > 1) {
        _items[name] = _items[name]! - 1;
      } else {
        _items.remove(name);
        _selectedItemNames.remove(name);
      }
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removeSelectedFromCart() {
    for (var name in _selectedItemNames.toList()) {
      _items.remove(name);
    }
    _selectedItemNames.clear();
    _saveToPrefs();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _selectedItemNames.clear();
    _saveToPrefs();
    notifyListeners();
  }
}
