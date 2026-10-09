import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/furniture_provider.dart';
import '../../models/furniture_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _searchQuery = "";

  void _showCategoryManagementSheet(BuildContext context, FurnitureProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getCard(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer<FurnitureProvider>(
        builder: (context, p, _) {
          final categories = p.editableCategories;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "จัดการหมวดหมู่สินค้า",
                      style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: AppColors.primary, size: 28),
                      tooltip: "เพิ่มหมวดหมู่ใหม่",
                      onPressed: () {
                        _promptAddCategory(context, p);
                      },
                    ),
                  ],
                ),
                Text(
                  "แตะเพื่อแก้ไขชื่อ หรือแตะไอคอนถังขยะเพื่อลบหมวดหมู่",
                  style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.getSurface(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          dense: true,
                          title: Text(cat, style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.w600)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                                onPressed: () => _promptRenameCategory(context, p, cat),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                onPressed: () => _confirmDeleteCategory(context, p, cat),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _promptAddCategory(BuildContext context, FurnitureProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        title: Text("เพิ่มหมวดหมู่ใหม่", style: TextStyle(color: AppColors.getTextPrimary(context))),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: AppColors.getTextPrimary(context)),
          decoration: InputDecoration(
            hintText: "กรอกชื่อหมวดหมู่",
            hintStyle: TextStyle(color: AppColors.getTextSecondary(context).withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.getSurface(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("ยกเลิก", style: TextStyle(color: AppColors.getTextSecondary(context)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                provider.addCategory(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text("เพิ่ม"),
          ),
        ],
      ),
    );
  }

  void _promptRenameCategory(BuildContext context, FurnitureProvider provider, String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        title: Text("แก้ไขชื่อหมวดหมู่", style: TextStyle(color: AppColors.getTextPrimary(context))),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: AppColors.getTextPrimary(context)),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.getSurface(context),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("ยกเลิก", style: TextStyle(color: AppColors.getTextSecondary(context)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                provider.renameCategory(oldName, val);
                Navigator.pop(ctx);
              }
            },
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, FurnitureProvider provider, String cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        title: Text("ลบหมวดหมู่ \"$cat\"", style: TextStyle(color: AppColors.getTextPrimary(context))),
        content: Text(
          "สินค้าในหมวดหมู่นี้จะถูกเปลี่ยนหมวดหมู่เป็น Others",
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("ยกเลิก", style: TextStyle(color: AppColors.getTextSecondary(context)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              provider.deleteCategory(cat);
              Navigator.pop(ctx);
            },
            child: const Text("ลบ"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            "ระบบจัดการสินค้า (Admin Dashboard)",
            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.getTextPrimary(context)),
            onPressed: () => context.pop(),
          ),
        ),
        body: Consumer<FurnitureProvider>(
          builder: (context, provider, child) {
            final allItems = provider.items;
            final filteredItems = allItems.where((item) {
              if (_searchQuery.isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return item.name.toLowerCase().contains(q) ||
                  item.category.toLowerCase().contains(q) ||
                  item.subtitle.toLowerCase().contains(q);
            }).toList();

            return Column(
              children: [
                _buildHeaderStats(context, allItems.length, provider.editableCategories.length, provider),
                _buildAddFurnitureButton(context),
                _buildSearchBar(context),
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Text(
                            "ไม่พบรายการสินค้าที่ค้นหา",
                            style: TextStyle(color: AppColors.getTextSecondary(context)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return _buildFurnitureAdminTile(context, item, provider);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddFurnitureButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => context.push('/admin/add-edit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add),
          label: const Text("เพิ่มสินค้าใหม่", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHeaderStats(BuildContext context, int totalCount, int categoriesCount, FurnitureProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            "สินค้าทั้งหมด",
            "$totalCount รายการ",
            Icons.inventory_2_outlined,
            null,
          ),
          Container(width: 1, height: 40, color: AppColors.getTextSecondary(context).withValues(alpha: 0.2)),
          _buildStatItem(
            context,
            "หมวดหมู่สินค้า",
            "$categoriesCount หมวดหมู่",
            Icons.category_outlined,
            () => _showCategoryManagementSheet(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13)),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 14, color: AppColors.primary),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.getSurface(context).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          style: TextStyle(color: AppColors.getTextPrimary(context)),
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: AppColors.getTextSecondary(context)),
            hintText: "ค้นหาสินค้าเพื่อแก้ไขหรือลบ...",
            hintStyle: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 14),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim();
            });
          },
        ),
      ),
    );
  }

  Widget _buildFurnitureAdminTile(BuildContext context, Furniture item, FurnitureProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 50,
            height: 50,
            color: AppColors.getSurface(context),
            child: Image.asset(
              item.image,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.chair, color: AppColors.primary),
            ),
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              "${item.category} • ฿${item.price.toStringAsFixed(0)}",
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              item.modelPath.split('/').last,
              style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 26),
              tooltip: "แก้ไขสินค้า",
              onPressed: () {
                context.push('/admin/add-edit', extra: item);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
              tooltip: "ลบสินค้า",
              onPressed: () => _confirmDelete(context, item, provider),
            ),
          ],
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
          "คุณต้องการลบสินค้า \"${item.name}\" ออกจากระบบใช่หรือไม่?",
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
}
