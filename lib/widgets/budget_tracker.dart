import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/budget_provider.dart';
import '../core/providers/cart_provider.dart';

class BudgetTrackerWidget extends StatelessWidget {
  const BudgetTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<BudgetProvider, CartProvider>(
      builder: (context, budgetProvider, cartProvider, child) {
        final total = cartProvider.totalPrice;
        final limit = budgetProvider.budgetLimit;
        final isOver = budgetProvider.isOverBudget(total);
        final progress = budgetProvider.getProgress(total);
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getSurface(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadow(context),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: isOver ? Border.all(color: AppColors.error, width: 2) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Budget Tracker",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showEditBudget(context, budgetProvider),
                    child: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.background(context),
                    valueColor: AlwaysStoppedAnimation<Color>(isOver ? AppColors.error : AppColors.interactive(context)),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "฿${total.toInt()} / ฿${limit.toInt()}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOver ? AppColors.error : AppColors.textSecondary(context),
                    ),
                  ),
                  if (isOver)
                    const Text(
                      "Over Budget!",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditBudget(BuildContext context, BudgetProvider provider) {
    final controller = TextEditingController(text: provider.budgetLimit.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Your Budget"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Amount (฿)",
            hintText: "Enter your budget limit",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                provider.setBudget(val);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
