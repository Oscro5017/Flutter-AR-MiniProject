import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/compare_provider.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Compare Furniture"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Consumer<CompareProvider>(
              builder: (context, compare, _) => IconButton(
                icon: Icon(Icons.delete_sweep_outlined, color: AppColors.getTextSecondary(context)), 
                onPressed: () => compare.clearCompare(),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<CompareProvider>(
          builder: (context, compare, _) {
            final items = compare.compareList;
  
            if (items.isEmpty) {
              return const Center(
                child: Text("เพิ่มสินค้าเพื่อเปรียบเทียบ (สูงสุด 3 ชิ้น)", style: TextStyle(color: Colors.grey)),
              );
            }
  
            return LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > 800;
                final labelWidth = isLandscape ? 160.0 : 100.0;
                final itemWidth = isLandscape ? (constraints.maxWidth - labelWidth) / items.length : 140.0;
                final minTableWidth = labelWidth + (items.length * itemWidth);

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: SizedBox(
                        width: isLandscape ? constraints.maxWidth : minTableWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Header Row
                            Row(
                              children: [
                                SizedBox(
                                  width: labelWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      "Feature", 
                                      style: TextStyle(
                                        color: AppColors.getTextPrimary(context), 
                                        fontWeight: FontWeight.bold,
                                        fontSize: isLandscape ? 16 : 14,
                                      )
                                    ),
                                  ),
                                ),
                                ...items.map((item) => SizedBox(
                                  width: itemWidth,
                                  child: _buildProductHeader(context, item, compare, isLandscape),
                                )),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            _buildCompareRow(context, "Price", items.map((e) => "฿${e.price.toInt()}").toList(), labelWidth, itemWidth),
                            _buildCompareRow(context, "Category", items.map((e) => e.category).toList(), labelWidth, itemWidth),
                            _buildCompareRow(context, "Rating", items.map((e) => e.rating.toString()).toList(), labelWidth, itemWidth, isRating: true),
                            _buildCompareRow(context, "Dimensions", items.map((e) => e.dimensions).toList(), labelWidth, itemWidth),
                            _buildCompareRow(context, "Material", items.map((e) => e.material).toList(), labelWidth, itemWidth),
                            _buildCompareRow(context, "Weight", items.map((e) => e.weight).toList(), labelWidth, itemWidth),
                            
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, dynamic item, CompareProvider provider, bool isLandscape) {
    final imgSize = isLandscape ? 100.0 : 80.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: imgSize,
                height: imgSize,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)
                  ],
                ),
                child: Image.asset(item.image, fit: BoxFit.contain),
              ),
              Positioned(
                top: -10,
                right: -10,
                child: GestureDetector(
                  onTap: () => provider.toggleCompare(item),
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.error,
                    child: Icon(Icons.close, color: Colors.white, size: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getTextPrimary(context), 
              fontSize: isLandscape ? 14 : 12, 
              fontWeight: FontWeight.bold
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompareRow(BuildContext context, String label, List<String> values, double labelWidth, double itemWidth, {bool isRating = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.getTextSecondary(context).withValues(alpha: 0.1))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(label, style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
          ...values.map((val) => SizedBox(
            width: itemWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    val, 
                    style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
                  ),
                  if (isRating) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: AppColors.rating, size: 14),
                  ],
                ],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}
