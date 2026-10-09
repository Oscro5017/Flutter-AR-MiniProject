import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/favorite_provider.dart';
import '../../widgets/furniture_card.dart';
import '../../widgets/framed_icon_button.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("รายการที่ชอบ"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
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
          currentIndex: 3,
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor?.withValues(alpha: 0.8),
          onTap: (index) {
            switch (index) {
              case 0: context.go("/home"); break;
              case 1: context.go("/catalog"); break;
              case 2: context.go("/scan"); break;
              case 3: break;
              case 4: context.go("/profile"); break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chair_outlined), label: "Catalog"),
            BottomNavigationBarItem(icon: Icon(Icons.view_in_ar_outlined), label: "AR"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorite"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
          ],
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            context.go("/home");
          },
          child: Consumer<FavoriteProvider>(
            builder: (context, favProvider, _) {
              final favorites = favProvider.favorites;
    
              if (favorites.isEmpty) {
                return const Center(
                  child: Text("ยังไม่มีรายการที่ชอบ", style: TextStyle(color: Colors.grey)),
                );
              }
    
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = constraints.maxWidth > 600;
                  final crossAxisCount = isLandscape ? 3 : 2;
                  final childAspectRatio = isLandscape ? 1.0 : 0.68;

                  return GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final item = favorites[index];
                      return FurnitureCard(
                        furniture: item,
                        onTap: () => context.push("/detail", extra: item),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
