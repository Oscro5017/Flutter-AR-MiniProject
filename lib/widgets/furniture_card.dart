import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/furniture_model.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/favorite_provider.dart';
import '../core/providers/compare_provider.dart';
import '../core/providers/cart_provider.dart';
import '../core/providers/budget_provider.dart';
import '../core/providers/user_provider.dart';

class FurnitureCard extends StatelessWidget {
  final Furniture furniture;
  final VoidCallback onTap;

  const FurnitureCard({
    super.key,
    required this.furniture,
    required this.onTap,
  });

  Widget _buildCardImage(BuildContext context, String path) {
    if (path.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.getSurface(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chair_outlined, size: 36, color: AppColors.primary.withValues(alpha: 0.8)),
              const SizedBox(height: 4),
              Text(
                "3D Model",
                style: TextStyle(fontSize: 10, color: AppColors.getTextSecondary(context), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 40),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 40),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 40),
        );
      }
      return const Icon(Icons.chair, size: 40);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = context.watch<UserProvider>().isAdmin;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: isAdmin ? Border.all(color: AppColors.primary.withValues(alpha: 0.35)) : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.getShadow(context),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Hero(
                      tag: 'furniture_${furniture.name}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _buildCardImage(context, furniture.image),
                        ),
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favoriteProvider, _) {
                        final isFavorite = favoriteProvider.isFavorite(furniture);
                        return GestureDetector(
                          onTap: () => favoriteProvider.toggleFavorite(furniture),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.card(context).withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.getShadow(context),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? AppColors.error : AppColors.textSecondary(context),
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Compare Button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Consumer<CompareProvider>(
                      builder: (context, compareProvider, _) {
                        final isInCompare = compareProvider.isInCompare(furniture);
                        return GestureDetector(
                          onTap: () => compareProvider.toggleCompare(furniture),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.card(context).withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.getShadow(context),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.compare_arrows_rounded,
                              color: isInCompare ? AppColors.interactive(context) : AppColors.textSecondary(context),
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Admin Quick Edit Button
                  if (isAdmin)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          context.push('/admin/add-edit', extra: furniture);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.getShadow(context),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Info Section
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Category right below the image
                    Text(
                      furniture.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      furniture.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Rating, ขายแล้ว, Prices and Cart Button at the bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left part: Rating & sold count
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, size: 12, color: AppColors.rating),
                                    const SizedBox(width: 4),
                                    Text(
                                      furniture.rating.toString(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (furniture.soldCount > 0)
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "ขายแล้ว ${furniture.soldCount}",
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textSecondary(context).withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Right part: Prices & Add to Cart button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "฿${furniture.price.toInt()}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Consumer2<CartProvider, BudgetProvider>(
                              builder: (context, cart, budget, _) => GestureDetector(
                                onTap: () {
                                  if (budget.isOverBudget(cart.totalPrice + furniture.price)) {
                                    _showBudgetWarning(context, () {
                                      cart.addToCart(furniture);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("เพิ่มลงตะกร้าแล้ว (เกินงบประมาณ)"), duration: Duration(seconds: 1)),
                                      );
                                    });
                                  } else {
                                    cart.addToCart(furniture);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("เพิ่มลงตะกร้าแล้ว"), duration: Duration(seconds: 1)),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetWarning(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text("Over Budget!"),
          ],
        ),
        content: const Text("Adding this item will exceed your set budget. Do you still want to add it?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text("Add Anyway"),
          ),
        ],
      ),
    );
  }
}
