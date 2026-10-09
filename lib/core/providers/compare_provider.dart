import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/furniture_model.dart';
import '../../data/dummy_furniture.dart';

class CompareProvider extends ChangeNotifier {
  final List<Furniture> _compareList = [];
  static const String _storageKey = 'compare_list_names';

  List<Furniture> get compareList => _compareList;

  CompareProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_storageKey);
    if (names != null) {
      _compareList.clear();
      for (var name in names) {
        try {
          final item = furnitureList.firstWhere((f) => f.name == name);
          _compareList.add(item);
        } catch (_) {}
      }
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final names = _compareList.map((e) => e.name).toList();
    await prefs.setStringList(_storageKey, names);
  }

  bool isInCompare(Furniture furniture) {
    return _compareList.any((item) => item.name == furniture.name);
  }

  void toggleCompare(Furniture furniture) {
    final index = _compareList.indexWhere((item) => item.name == furniture.name);
    if (index >= 0) {
      _compareList.removeAt(index);
    } else if (_compareList.length < 3) {
      _compareList.add(furniture);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void clearCompare() {
    _compareList.clear();
    _saveToPrefs();
    notifyListeners();
  }
}
