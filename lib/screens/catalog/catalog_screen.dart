import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/providers/furniture_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../widgets/furniture_card.dart';
import '../../widgets/app_search_bar.dart';
import '../../widgets/budget_tracker.dart';
import '../../widgets/category_chip.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/framed_icon_button.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _searchQuery = "";
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
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.categories.any((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();

    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Furniture Catalog"),
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
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                onPressed: () => context.push('/admin/add-edit'),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("เพิ่มสินค้า", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor?.withValues(alpha: 0.8),
          onTap: (index) {
            switch (index) {
              case 0: context.go("/home"); break;
              case 1: break;
              case 2: context.go("/scan"); break;
              case 3: context.go("/favorite"); break;
              case 4: context.go("/profile"); break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chair), label: "Catalog"),
            BottomNavigationBarItem(icon: Icon(Icons.view_in_ar_outlined), label: "AR"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: "Favorite"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            context.go("/home");
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > 600;
              final crossAxisCount = isLandscape ? 3 : 2;
              final childAspectRatio = isLandscape ? 1.0 : 0.68;
  
              return CustomScrollView(
                slivers: [
                  // 1. Search Bar
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverToBoxAdapter(
                      child: AppSearchBar(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),

                  // 2. Categories
                  SliverToBoxAdapter(
                    child: _buildCategories(context, categories),
                  ),

                  // 3. Budget Tracker
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverToBoxAdapter(
                      child: BudgetTrackerWidget(),
                    ),
                  ),

                  // 4. Furniture Grid
                  filteredList.isEmpty 
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text("ไม่พบสินค้าที่ค้นหา", style: TextStyle(color: Colors.grey))),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: childAspectRatio,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = filteredList[index];
                              return FurnitureCard(
                                furniture: item,
                                onTap: () => context.push("/detail", extra: item),
                              );
                            },
                            childCount: filteredList.length,
                          ),
                        ),
                      ),
                  
                  // Bottom spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context, List<String> categories) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            title: category,
            selected: _selectedCategory == category,
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
          );
        },
      ),
    );
  }
}
