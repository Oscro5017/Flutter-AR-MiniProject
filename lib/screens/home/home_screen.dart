import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/furniture_model.dart';
import '../../core/providers/furniture_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/furniture_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/budget_tracker.dart';
import '../../widgets/framed_icon_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final furnitureProvider = context.watch<FurnitureProvider>();
    final userProvider = context.watch<UserProvider>();
    final isAdmin = userProvider.isAdmin;

    final allItems = furnitureProvider.items;
    final categories = furnitureProvider.categories;

    final filteredList = allItems.where((item) {
      final matchesCategory = _selectedCategory == "All" || item.categories.contains(_selectedCategory);
      return matchesCategory;
    }).toList();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("AR Furniture"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (isAdmin)
              FramedIconButton(
                icon: Icons.admin_panel_settings,
                tooltip: "Admin Dashboard",
                onPressed: () => context.push("/admin"),
              ),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor?.withValues(alpha: 0.8),
          onTap: (index) {
            switch (index) {
              case 0: break;
              case 1: context.go("/catalog"); break;
              case 2: context.go("/scan"); break;
              case 3: context.go("/favorite"); break;
              case 4: context.go("/profile"); break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chair_outlined), label: "Catalog"),
            BottomNavigationBarItem(icon: Icon(Icons.view_in_ar_outlined), label: "AR"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: "Favorite"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildUserInfo(context, userProvider),
                        const SizedBox(height: 24),
                        const BudgetTrackerWidget(),
                        const SizedBox(height: 24),
                        _buildSectionTitle(context, "Popular"),
                        const SizedBox(height: 16),
                        ...allItems.take(8).map((item) => _buildPopularItem(context, item)),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.getTextSecondary(context).withValues(alpha: 0.18),
                  ),
                  Expanded(
                    flex: 3,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildSectionTitle(context, "Categories"),
                        const SizedBox(height: 16),
                        _buildCategories(context, categories),
                        const SizedBox(height: 24),
                        _buildARBanner(context),
                        const SizedBox(height: 32),
                        _buildSectionTitle(context, "Recommended"),
                        const SizedBox(height: 16),
                        _buildFurnitureHorizontalList(context, filteredList),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 10),
                _buildUserInfo(context, userProvider),
                const SizedBox(height: 24),
                const BudgetTrackerWidget(),
                const SizedBox(height: 24),
                _buildSectionTitle(context, "Categories"),
                const SizedBox(height: 16),
                _buildCategories(context, categories),
                const SizedBox(height: 24),
                
                _buildARBanner(context),
                const SizedBox(height: 32),
                _buildSectionTitle(context, "Recommended"),
                const SizedBox(height: 16),
                _buildFurnitureHorizontalList(context, filteredList),
                
                const SizedBox(height: 32),
                _buildSectionTitle(context, "Popular"),
                const SizedBox(height: 16),
                ...allItems.take(5).map((item) => _buildPopularItem(context, item)),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, UserProvider userProvider) {
    final isAdmin = userProvider.isAdmin;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? "Admin Panel Active 🛡️" : "Good Day 👋",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(userProvider.userName, style: Theme.of(context).textTheme.headlineSmall),
                if (isAdmin) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "ADMIN",
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.go("/profile"),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: isAdmin ? AppColors.primary.withValues(alpha: 0.2) : AppColors.getSurface(context).withValues(alpha: 0.7),
            child: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: isAdmin ? AppColors.primary : AppColors.getTextSecondary(context).withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.getTextSecondary(context).withValues(alpha: 0.15)),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CategoryChip(
              title: cat,
              selected: _selectedCategory == cat,
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildARBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B3664).withValues(alpha: 0.82) : const Color(0xFFEAF5FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF9CCAF7).withValues(alpha: isDark ? 0.22 : 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Try Furniture in AR", 
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.interactive(context),
                    fontSize: 16, 
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 8),
                Text(
                  "Visualize furniture inside your room before buying.", 
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary(context), 
                    fontSize: 12
                  )
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => context.push("/scan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF2D3F50) : const Color(0xFF78B8FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              elevation: 0,
            ),
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }

  Widget _buildFurnitureHorizontalList(BuildContext context, List<Furniture> list) {
    if (list.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text("ไม่มีสินค้าในหมวดหมู่นี้", style: TextStyle(color: AppColors.getTextSecondary(context))),
      );
    }
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return Container(
            width: 190,
            margin: const EdgeInsets.only(right: 16, bottom: 10, top: 5),
            child: FurnitureCard(
              furniture: item,
              onTap: () => context.push("/detail", extra: item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularItem(BuildContext context, Furniture item) {
    return GestureDetector(
      onTap: () => context.push("/detail", extra: item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(item.image, fit: BoxFit.contain, errorBuilder: (_, __, _) => const Icon(Icons.chair, color: Colors.black12)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(item.category, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Text("฿${item.price.toInt()}", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
