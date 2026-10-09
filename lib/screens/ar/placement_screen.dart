import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/furniture_provider.dart';
import '../../models/furniture_model.dart';
import '../../widgets/framed_icon_button.dart';

class PlacementScreen extends StatefulWidget {
  final Furniture? initialFurniture;

  const PlacementScreen({
    super.key,
    this.initialFurniture,
  });

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  Furniture? selectedItem;
  final ScreenshotController screenshotController = ScreenshotController();
  bool _isCapturing = false;

  String _resolveModelSrc(String path) {
    if (path.startsWith('assets/') || path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return 'file://$path';
  }

  Widget _buildThumbnailImage(String path) {
    if (path.isEmpty) {
      return const Icon(Icons.chair, size: 24, color: AppColors.primary);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 24));
    } else if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 24));
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 24));
      }
      return const Icon(Icons.chair, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allItems = context.watch<FurnitureProvider>().items;

    if (selectedItem == null) {
      selectedItem = widget.initialFurniture ?? (allItems.isNotEmpty ? allItems[0] : null);
    }

    if (selectedItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("AR View")),
        body: const Center(child: Text("ไม่มีสินค้าให้แสดงผล")),
      );
    }

    final currentFurniture = selectedItem!;

    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            currentFurniture.name,
            style: TextStyle(color: AppColors.textPrimary(context)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
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
          child: Screenshot(
            controller: screenshotController,
            child: Stack(
              children: [
                // 3D/AR View
                ModelViewer(
                  key: ValueKey(currentFurniture.modelPath),
                  src: _resolveModelSrc(currentFurniture.modelPath),
                  alt: currentFurniture.name,
                  ar: true,
                  autoRotate: true, 
                  cameraControls: true,
                  shadowIntensity: 1.0,
                  backgroundColor: Colors.transparent,
                ),
                
                // AR Instruction Overlay
                Positioned(
                  left: 20,
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "แตะไอคอน AR เพื่อจำลองในห้องจริง", 
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.white, 
                            fontSize: 11
                          )
                        ),
                      ],
                    ),
                  ),
                ),
        
                // Capturing Overlay
                if (_isCapturing)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
  
                // Bottom Controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isLandscape = constraints.maxWidth > 600;
  
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: isLandscape ? 16 : 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context).withValues(alpha: 0.8),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Furniture Slider
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: allItems.length,
                                itemBuilder: (context, index) {
                                  final item = allItems[index];
                                  final isSelected = item.name == currentFurniture.name;
                                  return GestureDetector(
                                    onTap: () {
                                      if (item.name != currentFurniture.name) {
                                        setState(() {
                                          selectedItem = item;
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.card(context),
                                        borderRadius: BorderRadius.circular(12),
                                        border: isSelected ? Border.all(color: AppColors.interactive(context), width: 3) : null,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: _buildThumbnailImage(item.image),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            SizedBox(height: isLandscape ? 12 : 24),
                            
                            // Action Buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isCapturing ? null : () => _captureAndShare(currentFurniture, share: false),
                                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                                      label: const Text("Capture Photo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.card(context),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.share_outlined, color: AppColors.textPrimary(context)),
                                      onPressed: _isCapturing ? null : () => _captureAndShare(currentFurniture, share: true),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndShare(Furniture furniture, {bool share = true}) async {
    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await screenshotController.capture();
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/captured_ar_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await imagePath.writeAsBytes(image);

        if (mounted) {
          if (share) {
            await Share.shareXFiles([XFile(imagePath.path)], text: 'Check out this ${furniture.name} in my room!');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('บันทึกรูปภาพลงในเครื่องเรียบร้อยแล้ว')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }
}
