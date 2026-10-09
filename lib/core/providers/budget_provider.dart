import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  double _budgetLimit = 50000.0;
  static const String _storageKey = 'budget_limit';

  double get budgetLimit => _budgetLimit;

  BudgetProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBudget = prefs.getDouble(_storageKey);
    if (savedBudget != null) {
      _budgetLimit = savedBudget;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_storageKey, _budgetLimit);
  }

  void setBudget(double value) {
    _budgetLimit = value;
    _saveToPrefs();
    notifyListeners();
  }

  bool isOverBudget(double totalCost) {
    return totalCost > _budgetLimit;
  }

  double getRemaining(double totalCost) {
    return _budgetLimit - totalCost;
  }
  
  double getProgress(double totalCost) {
    if (_budgetLimit == 0) return 1.0;
    final progress = totalCost / _budgetLimit;
    return progress > 1.0 ? 1.0 : progress;
  }
}
