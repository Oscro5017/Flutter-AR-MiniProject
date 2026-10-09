import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/user_provider.dart';
import '../cart/cart_screen.dart';
import '../compare/compare_screen.dart';
import '../settings/settings_screen.dart';
import '../admin/admin_dashboard_screen.dart';

enum _ProfilePanel { cart, compare, settings, adminDashboard }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  _ProfilePanel? _selectedPanel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Profile", style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 4,
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor?.withValues(alpha: 0.8),
          onTap: (index) {
            switch (index) {
              case 0: context.go("/home"); break;
              case 1: context.go("/catalog"); break;
              case 2: context.go("/scan"); break;
              case 3: context.go("/favorite"); break;
              case 4: break;
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chair_outlined), label: "Catalog"),
            BottomNavigationBarItem(icon: Icon(Icons.view_in_ar_outlined), label: "AR"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: "Favorite"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            context.go("/home");
          },
          child: OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.landscape) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 2,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _buildProfileHeader(context),
                          const SizedBox(height: 24),
                          ..._buildMenuItems(context, true),
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
                      child: _selectedPanel == null
                          ? Center(
                              child: Text(
                                "เลือกเมนูเพื่อดูรายละเอียด",
                                style: TextStyle(color: AppColors.getTextSecondary(context)),
                              ),
                            )
                          : _buildSelectedPanel(),
                    ),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.only(top: 24),
                children: [
                  _buildProfileHeader(context),
                  const SizedBox(height: 24),
                  ..._buildMenuItems(context, false),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final isAdmin = userProvider.isAdmin;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: isAdmin ? AppColors.primary.withValues(alpha: 0.2) : const Color(0xCBFFFFFF),
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.person,
                    size: 50,
                    color: isAdmin ? AppColors.primary : const Color(0xFF292929),
                  ),
                ),
                if (isAdmin)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, size: 18, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              userProvider.userName,
              style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userProvider.userEmail,
              style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
            ),
            const SizedBox(height: 12),
            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isAdmin ? AppColors.primary : AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAdmin ? Icons.shield_outlined : Icons.person_outline,
                    size: 16,
                    color: isAdmin ? Colors.white : AppColors.getTextPrimary(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAdmin ? "System Admin" : "General User",
                    style: TextStyle(
                      color: isAdmin ? Colors.white : AppColors.getTextPrimary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, bool isLandscape) {
    final userProvider = context.watch<UserProvider>();
    final isAdmin = userProvider.isAdmin;

    return [
      if (isAdmin) ...[
        _buildMenuItem(
          context,
          Icons.admin_panel_settings_outlined,
          "ระบบจัดการสินค้า (Admin Dashboard)",
          () => _openPanel(context, _ProfilePanel.adminDashboard, isLandscape, "/admin"),
          badgeColor: AppColors.primary,
        ),
      ],
      _buildMenuItem(context, Icons.shopping_cart_outlined, "ตะกร้าสินค้า", () {
        _openPanel(context, _ProfilePanel.cart, isLandscape, "/cart");
      }),
      _buildMenuItem(context, Icons.compare_arrows_rounded, "รายการเปรียบเทียบ", () {
        _openPanel(context, _ProfilePanel.compare, isLandscape, "/compare");
      }),
      _buildMenuItem(context, Icons.settings_outlined, "Settings", () {
        _openPanel(context, _ProfilePanel.settings, isLandscape, "/settings");
      }),
      const SizedBox(height: 12),
      // Sign Out
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          onTap: () {
            userProvider.logout();
            context.go("/login");
          },
        ),
      ),
    ];
  }

  void _openPanel(BuildContext context, _ProfilePanel panel, bool isLandscape, String route) {
    if (isLandscape) {
      setState(() {
        _selectedPanel = panel;
      });
    } else {
      context.push(route);
    }
  }

  Widget _buildSelectedPanel() {
    switch (_selectedPanel) {
      case _ProfilePanel.cart:
        return const CartScreen();
      case _ProfilePanel.compare:
        return const CompareScreen();
      case _ProfilePanel.settings:
        return const SettingsScreen();
      case _ProfilePanel.adminDashboard:
        return const AdminDashboardScreen();
      case null:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? badgeColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: badgeColor != null ? Border.all(color: badgeColor, width: 1.5) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: badgeColor ?? AppColors.getTextSecondary(context)),
        title: Text(
          title,
          style: TextStyle(
            color: badgeColor ?? AppColors.getTextPrimary(context),
            fontSize: 16,
            fontWeight: badgeColor != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.getTextSecondary(context).withValues(alpha: 0.3)),
        onTap: onTap,
      ),
    );
  }
}
