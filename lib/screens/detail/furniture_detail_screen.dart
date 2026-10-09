import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/furniture_model.dart';
import '../../core/providers/furniture_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/providers/compare_provider.dart';
import '../../core/providers/budget_provider.dart';
import '../../widgets/framed_icon_button.dart';

class FurnitureDetailScreen extends StatelessWidget {
  final Furniture furniture;

  const FurnitureDetailScreen({
    super.key,
    required this.furniture,
  });

  String _resolveModelSrc(String path) {
    if (path.startsWith('assets/') || path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return 'file://$path';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();
    final furnitureProvider = context.watch<FurnitureProvider>();
    final isAdmin = userProvider.isAdmin;

    // Get up-to-date furniture item from provider in case it was edited
    final currentItem = furnitureProvider.findByName(furniture.name) ?? furniture;

    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            currentItem.name,
            style: TextStyle(color: AppColors.textPrimary(context)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
          leading: FramedIconButton(
            icon: Icons.arrow_back,
            tooltip: "Back",
            margin: const EdgeInsets.only(left: 8),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go("/home");
              }
            },
          ),
          actions: [
            if (isAdmin) ...[
              FramedIconButton(
                icon: Icons.edit_note_rounded,
                tooltip: "Edit Product",
                onPressed: () {
                  context.push('/admin/add-edit', extra: currentItem);
                },
              ),
              FramedIconButton(
                icon: Icons.delete_outline_rounded,
                tooltip: "Delete Product",
                onPressed: () => _confirmDelete(context, currentItem, furnitureProvider),
              ),
            ],
            FramedIconButton(
              icon: Icons.compare_arrows_rounded,
              tooltip: "Compare",
              onPressed: () => context.push("/compare"),
            ),
            FramedIconButton(
              icon: Icons.shopping_cart_outlined,
              tooltip: "My Cart",
              onPressed: () => context.push("/cart"),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go("/home");
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight && constraints.maxWidth > 600;

              if (isLandscape) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side: 3D Model
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2B3664).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Stack(
                          children: [
                            ModelViewer(
                              key: ValueKey(currentItem.modelPath),
                              src: _resolveModelSrc(currentItem.modelPath),
                              alt: currentItem.name,
                              ar: true,
                              autoRotate: true,
                              cameraControls: true,
                              shadowIntensity: 1.0,
                              backgroundColor: Colors.transparent,
                            ),
                            const Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Text(
                                  "แตะไอคอนสี่เหลี่ยม AR ตรงมุมภาพ เพื่อเปิดกล้องและวางเฟอร์นิเจอร์ในห้องของคุณ",
                                  style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: AppColors.getTextSecondary(context).withValues(alpha: 0.18),
                    ),
                    // Right Side: Info
                    Expanded(
                      flex: 1,
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          _buildInfoCard(context, _buildMainInfo(context, currentItem, isDark)),
                          const SizedBox(height: 20),
                          _buildInfoCard(context, _buildPriceRatingInfo(context, currentItem, isDark)),
                          const SizedBox(height: 32),
                          _buildInfoCard(context, _buildDescriptionSection(context, currentItem)),
                          const SizedBox(height: 40),
                          _buildActionButtonsGrid(context, currentItem),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView(
                children: [
                  // 3D Model Viewer
                  Container(
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2B3664).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.2),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: ModelViewer(
                        key: ValueKey(currentItem.modelPath),
                        src: _resolveModelSrc(currentItem.modelPath),
                        alt: currentItem.name,
                        ar: true,
                        autoRotate: true,
                        cameraControls: true,
                        shadowIntensity: 1.0,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              "💡 แตะไอคอน AR ที่มุมขวาล่างของภาพเพื่อลองวางในห้องจริง",
                              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        _buildInfoCard(context, _buildMainInfo(context, currentItem, isDark)),
                        const SizedBox(height: 20),
                        _buildInfoCard(context, _buildPriceRatingInfo(context, currentItem, isDark)),
                        const SizedBox(height: 32),
                        _buildInfoCard(context, _buildDescriptionSection(context, currentItem)),
                        const SizedBox(height: 40),
                        _buildActionButtonsGrid(context, currentItem),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Furniture item, FurnitureProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        title: Text("ยืนยันการลบสินค้า", style: TextStyle(color: AppColors.getTextPrimary(context))),
        content: Text(
          "คุณต้องการลบสินค้า \"${item.name}\" ใช่หรือไม่?",
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("ยกเลิก", style: TextStyle(color: AppColors.getTextSecondary(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              provider.deleteFurniture(item.name);
              Navigator.pop(ctx);
              context.go('/catalog');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ลบสินค้า "${item.name}" เรียบร้อยแล้ว')),
              );
            },
            child: const Text("ลบสินค้า", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context, Furniture item, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(
                  color: AppColors.textPrimary(context), 
                  fontSize: 24, 
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                item.category,
                style: TextStyle(
                  color: AppColors.textSecondary(context), 
                  fontSize: 16
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2B303B) : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "ขายแล้ว ${item.soldCount}",
            style: const TextStyle(
              color: AppColors.primary, 
              fontSize: 12, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRatingInfo(BuildContext context, Furniture item, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.rating, size: 24),
            const SizedBox(width: 8),
            Text(
              item.rating.toString(),
              style: TextStyle(
                color: AppColors.textPrimary(context), 
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        Text(
          "฿${item.price.toInt()}",
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
            fontSize: 26, 
            fontWeight: FontWeight.w900
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context, Furniture item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Description", 
              style: TextStyle(
                color: AppColors.textPrimary(context), 
                fontSize: 18, 
                fontWeight: FontWeight.bold
              )
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text("Detailed Info"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.interactive(context),
                side: BorderSide(color: AppColors.interactive(context).withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          item.description,
          style: TextStyle(
            color: AppColors.textSecondary(context), 
            fontSize: 14, 
            height: 1.6
          ),
        ),
        if (item.dimensions.isNotEmpty || item.material.isNotEmpty || item.weight.isNotEmpty) ...[
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (item.dimensions.isNotEmpty) _buildSpecItem(context, "ขนาด", item.dimensions),
              if (item.material.isNotEmpty) _buildSpecItem(context, "วัสดุ", item.material),
              if (item.weight.isNotEmpty) _buildSpecItem(context, "น้ำหนัก", item.weight),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSpecItem(BuildContext context, String label, String val) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButtonsGrid(BuildContext context, Furniture item) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        Consumer2<CartProvider, BudgetProvider>(
          builder: (context, cart, budget, _) => _buildActionButton(
            context, 
            "Add to Cart", 
            Icons.shopping_cart_outlined, 
            Colors.white, 
            AppColors.interactive(context),
            onPressed: () {
              if (budget.isOverBudget(cart.totalPrice + item.price)) {
                _showBudgetWarning(context, () {
                  cart.addToCart(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("เพิ่มลงตะกร้าแล้ว (เกินงบประมาณ)"), duration: Duration(seconds: 1)),
                  );
                });
              } else {
                cart.addToCart(item);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("เพิ่มลงตะกร้าแล้ว"), duration: Duration(seconds: 1)),
                );
              }
            },
          ),
        ),
        Consumer<FavoriteProvider>(
          builder: (context, fav, _) => _buildOutlineButton(
            context, 
            fav.isFavorite(item) ? "Favorited" : "Favorite", 
            fav.isFavorite(item) ? Icons.favorite : Icons.favorite_border,
            color: fav.isFavorite(item) ? AppColors.error : null,
            onPressed: () => fav.toggleFavorite(item),
          ),
        ),
        Consumer<CompareProvider>(
          builder: (context, compare, _) => _buildOutlineButton(
            context, 
            compare.isInCompare(item) ? "In Compare" : "Add Compare", 
            Icons.compare_arrows_rounded,
            color: compare.isInCompare(item) ? AppColors.interactive(context) : null,
            onPressed: () => compare.toggleCompare(item),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.getTextSecondary(context).withValues(alpha: 0.18),
        ),
      ),
      child: child,
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

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color textColor, Color bgColor, {required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildOutlineButton(BuildContext context, String label, IconData icon, {Color? color, required VoidCallback onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      style: OutlinedButton.styleFrom(
        backgroundColor: color?.withValues(alpha: 0.12) ?? AppColors.getSurface(context).withValues(alpha: 0.8),
        foregroundColor: color ?? (isDark ? Colors.white70 : Colors.black87),
        side: BorderSide(color: color?.withValues(alpha: 0.65) ?? (isDark ? Colors.white38 : Colors.black26)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
