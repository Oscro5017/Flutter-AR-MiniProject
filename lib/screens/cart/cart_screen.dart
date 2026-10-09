import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/soft_button.dart';
import '../../widgets/soft_container.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/budget_provider.dart';
import '../../widgets/budget_tracker.dart';
import '../../data/dummy_furniture.dart';
import '../../models/furniture_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Widget _buildCartItemImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 30));
    } else if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 30));
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 30));
      }
      return const Icon(Icons.chair, size: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("My Cart"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Consumer<CartProvider>(
              builder: (context, cart, _) => cart.itemNames.isNotEmpty
                  ? TextButton.icon(
                      onPressed: () => cart.clearCart(),
                      icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 20),
                      label: const Text("ล้างตะกร้า", style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer2<CartProvider, BudgetProvider>(
          builder: (context, cart, budget, _) {
            if (cart.itemNames.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.getTextSecondary(context).withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text("ตะกร้าสินค้าว่างเปล่า", style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/catalog'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("เลือกชมสินค้า"),
                    ),
                  ],
                ),
              );
            }

            final cartItems = cart.itemNames.map((name) {
              final furniture = furnitureList.firstWhere(
                (f) => f.name == name,
                orElse: () => Furniture(
                  name: name,
                  subtitle: '',
                  categories: const ['General'],
                  price: 0,
                  image: '',
                  modelPath: '',
                  rating: 5,
                ),
              );
              final qty = cart.getQuantity(name);
              final isSelected = cart.isItemSelected(name);
              return {'data': furniture, 'qty': qty, 'selected': isSelected};
            }).toList();

            final selectedPrice = cart.selectedTotalPrice;
            final isOverBudget = budget.isOverBudget(selectedPrice);

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: BudgetTrackerWidget(),
                ),
                _buildSelectAllHeader(context, cart),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) => _buildCartItem(context, cartItems[index], cart),
                  ),
                ),
                _buildSummarySection(context, cart, selectedPrice, isOverBudget),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectAllHeader(BuildContext context, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: cart.isAllSelected,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              cart.selectAll(val ?? false);
            },
          ),
          Text(
            "เลือกทั้งหมด (${cart.itemNames.length} รายการ)",
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            "เลือกแล้ว ${cart.selectedItemNames.length} ชิ้น",
            style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item, CartProvider cart) {
    final furniture = item['data'] as Furniture;
    final qty = item['qty'] as int;
    final isSelected = item['selected'] as bool;

    return SoftContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (_) {
              cart.toggleItemSelection(furniture.name);
            },
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: _buildCartItemImage(furniture.image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  furniture.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary(context)),
                ),
                Text(
                  furniture.category,
                  style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  "฿${furniture.price.toInt()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => cart.removeFromCart(furniture.name),
                icon: Icon(Icons.remove_circle_outline, color: AppColors.getTextSecondary(context), size: 22),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text("$qty", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.getTextPrimary(context))),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => cart.addToCart(furniture),
                icon: Icon(Icons.add_circle_outline, color: AppColors.getTextSecondary(context), size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, CartProvider cart, double selectedPrice, bool isOverBudget) {
    final selectedCount = cart.selectedItemCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ยอดรวมชำระ ($selectedCount ชิ้น)",
                style: TextStyle(fontSize: 15, color: AppColors.getTextSecondary(context)),
              ),
              Text(
                "฿${selectedPrice.toInt()}",
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.w900, 
                  color: isOverBudget ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SoftButton(
              onPressed: () {
                if (selectedCount == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("กรุณาเลือกอย่างน้อย 1 รายการเพื่อสั่งซื้อ")),
                  );
                  return;
                }
                if (isOverBudget) {
                  _showOverBudgetWarning(context, () {
                    context.push('/checkout');
                  });
                } else {
                  context.push('/checkout');
                }
              },
              child: Center(
                child: Text(
                  "ดำเนินการสั่งซื้อ ($selectedCount)",
                  style: TextStyle(
                    color: selectedCount == 0
                        ? Colors.grey
                        : (isOverBudget ? AppColors.error : AppColors.primary),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOverBudgetWarning(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        title: Text("Over Budget Warning", style: TextStyle(color: AppColors.getTextPrimary(context))),
        content: Text(
          "ราคารวมสินค้าที่เลือกเกินงบประมาณที่คุณตั้งไว้ คุณต้องการดำเนินการสั่งซื้อต่อหรือไม่?",
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ย้อนกลับ", style: TextStyle(color: AppColors.getTextSecondary(context))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("ดำเนินการต่อ", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
