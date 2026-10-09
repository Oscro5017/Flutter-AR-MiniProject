import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/providers/furniture_provider.dart';
import '../../models/furniture_model.dart';

class ScanRoomScreen extends StatefulWidget {
  const ScanRoomScreen({super.key});

  @override
  State<ScanRoomScreen> createState() => _ScanRoomScreenState();
}

class _ScanRoomScreenState extends State<ScanRoomScreen> {
  Furniture? selectedFurniture;

  String _resolveModelSrc(String path) {
    if (path.startsWith('assets/') || path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return 'file://$path';
  }

  Widget _buildCarouselImage(String path) {
    if (path.isEmpty) {
      return const Icon(Icons.chair, size: 28, color: AppColors.primary);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 28));
    } else if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 28));
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 28));
      }
      return const Icon(Icons.chair, size: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allItems = context.watch<FurnitureProvider>().items;

    if (selectedFurniture == null && allItems.isNotEmpty) {
      selectedFurniture = allItems[0];
    }
    
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        final favorites = favProvider.favorites;
        final List<Furniture> displayList = [
          ...favorites,
          ...allItems.where((item) => !favorites.any((fav) => fav.name == item.name))
        ];

        return Container(
          decoration: AppColors.backgroundDecoration(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
                onPressed: () => context.go("/home"),
              ),
              title: Text(
                selectedFurniture?.name ?? "Select Furniture",
                style: TextStyle(
                  color: AppColors.textPrimary(context), 
                  fontWeight: FontWeight.bold
                ),
              ),
              centerTitle: true,
            ),
            body: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) return;
                context.go("/home");
              },
              child: Column(
                children: [
                  // 1. Preview Section
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard.withValues(alpha: 0.8) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: selectedFurniture != null
                            ? ModelViewer(
                                key: ValueKey(selectedFurniture!.modelPath),
                                src: _resolveModelSrc(selectedFurniture!.modelPath),
                                alt: selectedFurniture!.name,
                                autoRotate: true,
                                cameraControls: true,
                                backgroundColor: Colors.transparent,
                                disableZoom: false,
                                ar: true,
                                arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                                arPlacement: ArPlacement.floor,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
  
                  // 2. Furniture Selection Carousel
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final item = displayList[index];
                        final isSelected = selectedFurniture?.name == item.name;
                        final isFavorite = favorites.any((fav) => fav.name == item.name);
  
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFurniture = item;
                            });
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                  ? AppColors.interactive(context).withValues(alpha: 0.5) 
                                  : AppColors.textSecondary(context).withValues(alpha: 0.1),
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected 
                                ? [BoxShadow(color: AppColors.interactive(context).withValues(alpha: 0.15), blurRadius: 10)] 
                                : null,
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: _buildCarouselImage(item.image),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
                                      child: Text(
                                        item.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? AppColors.interactive(context) : AppColors.textSecondary(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isFavorite && !isSelected)
                                  const Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(Icons.favorite, color: AppColors.error, size: 12),
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
  
                  // 3. Instruction Banner
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.interactive(context).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.interactive(context)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "แตะไอคอนสี่เหลี่ยม AR ตรงมุมภาพ เพื่อเปิดกล้องและวางเฟอร์นิเจอร์ในห้องของคุณ",
                              style: TextStyle(
                                fontSize: 12, 
                                color: AppColors.textPrimary(context).withValues(alpha: 0.8),
                                height: 1.5
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
  
                  TextButton(
                    onPressed: () => context.go("/home"),
                    child: Text(
                      "กลับสู่หน้าก่อนหน้า",
                      style: TextStyle(color: AppColors.textSecondary(context).withValues(alpha: 0.6)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
