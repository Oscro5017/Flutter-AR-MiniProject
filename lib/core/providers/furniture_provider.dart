import 'package:flutter/material.dart';
import '../../data/dummy_furniture.dart';
import '../../models/furniture_model.dart';

class FurnitureProvider extends ChangeNotifier {
  final List<Furniture> _items = List.from(furnitureList);

  final List<String> _customCategories = [
    'Living Room',
    'Bedroom',
    'Office',
    'Kitchen',
    'Bathroom',
    'Lighting',
    'Decoration',
    'Chair',
    'Table',
    'Sofa',
    'Bed',
    'Cabinet',
    'Lamp',
    'Appliance',
    'Others',
  ];

  List<Furniture> get items => List.unmodifiable(_items);

  List<String> get categories {
    final catSet = <String>{'All'};
    catSet.addAll(_customCategories);
    for (var item in _items) {
      catSet.addAll(item.categories);
    }
    return catSet.toList();
  }

  /// Returns categories excluding 'All' for forms and management
  List<String> get editableCategories {
    final catSet = <String>{};
    catSet.addAll(_customCategories);
    for (var item in _items) {
      catSet.addAll(item.categories.where((c) => c != 'All'));
    }
    return catSet.toList();
  }

  Furniture? findByName(String name) {
    try {
      return _items.firstWhere((item) => item.name == name);
    } catch (_) {
      return null;
    }
  }

  void addFurniture(Furniture item) {
    _items.insert(0, item);
    for (var c in item.categories) {
      if (c.isNotEmpty && !_customCategories.contains(c)) {
        _customCategories.add(c);
      }
    }
    notifyListeners();
  }

  void updateFurniture(String originalName, Furniture updatedItem) {
    final index = _items.indexWhere((element) => element.name == originalName);
    if (index != -1) {
      _items[index] = updatedItem;
      for (var c in updatedItem.categories) {
        if (c.isNotEmpty && !_customCategories.contains(c)) {
          _customCategories.add(c);
        }
      }
      notifyListeners();
    }
  }

  void deleteFurniture(String name) {
    _items.removeWhere((element) => element.name == name);
    notifyListeners();
  }

  void addCategory(String category) {
    final trimmed = category.trim();
    if (trimmed.isNotEmpty && !_customCategories.contains(trimmed)) {
      _customCategories.add(trimmed);
      notifyListeners();
    }
  }

  void renameCategory(String oldName, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || oldName == trimmed) return;

    final index = _customCategories.indexOf(oldName);
    if (index != -1) {
      _customCategories[index] = trimmed;
    } else {
      _customCategories.add(trimmed);
    }

    for (int i = 0; i < _items.length; i++) {
      if (_items[i].categories.contains(oldName)) {
        final newCats = _items[i].categories.map((c) => c == oldName ? trimmed : c).toList();
        _items[i] = _items[i].copyWith(categories: newCats);
      }
    }
    notifyListeners();
  }

  void deleteCategory(String categoryName) {
    if (categoryName == 'All') return;

    _customCategories.remove(categoryName);

    for (int i = 0; i < _items.length; i++) {
      if (_items[i].categories.contains(categoryName)) {
        final newCats = _items[i].categories.where((c) => c != categoryName).toList();
        if (newCats.isEmpty) newCats.add('Others');
        _items[i] = _items[i].copyWith(categories: newCats);
      }
    }
    notifyListeners();
  }
}
