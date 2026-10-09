import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/furniture_provider.dart';
import '../../models/furniture_model.dart';

class AddEditFurnitureScreen extends StatefulWidget {
  final Furniture? furniture;

  const AddEditFurnitureScreen({super.key, this.furniture});

  @override
  State<AddEditFurnitureScreen> createState() => _AddEditFurnitureScreenState();
}

class _AddEditFurnitureScreenState extends State<AddEditFurnitureScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _subtitleController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late TextEditingController _modelPathController;
  late TextEditingController _descriptionController;
  late TextEditingController _dimensionsController;
  late TextEditingController _materialController;
  late TextEditingController _weightController;

  final Set<String> _selectedCategories = {};

  bool get isEditing => widget.furniture != null;

  late final Future<List<String>> _presetModelsFuture;
  late final Future<List<String>> _presetImagesFuture;

  @override
  void initState() {
    super.initState();
    _presetModelsFuture = _loadAssetPresets(
      'assets/furniture_models/',
      const {'.glb', '.gltf'},
    );
    _presetImagesFuture = _loadAssetPresets(
      'assets/images/furniture/',
      const {'.png', '.jpg', '.jpeg', '.webp'},
    );
    final f = widget.furniture;
    _nameController = TextEditingController(text: f?.name ?? '');
    _subtitleController = TextEditingController(text: f?.subtitle ?? 'High Quality Furniture');
    _priceController = TextEditingController(text: f != null ? f.price.toStringAsFixed(0) : '');
    _imageController = TextEditingController(text: f?.image ?? '');
    _modelPathController = TextEditingController(
      text: f?.modelPath ?? 'assets/furniture_models/Couch_L.glb',
    );
    _descriptionController = TextEditingController(
      text: f?.description ?? 'สินค้าดีไซน์ทันสมัย เหมาะสำหรับการตกแต่งห้องอย่างมีสไตล์',
    );
    _dimensionsController = TextEditingController(text: f?.dimensions ?? '60 x 60 x 80 cm');
    _materialController = TextEditingController(text: f?.material ?? 'Wood & Premium Fabric');
    _weightController = TextEditingController(text: f?.weight ?? '12 kg');

    if (f != null && f.categories.isNotEmpty) {
      _selectedCategories.addAll(f.categories);
    } else {
      _selectedCategories.add('Living Room');
    }
  }

  Future<List<String>> _loadAssetPresets(
    String directory,
    Set<String> extensions,
  ) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().where((asset) {
      if (!asset.startsWith(directory)) return false;
      final extension = '.${asset.split('.').last.toLowerCase()}';
      return extensions.contains(extension);
    }).toList()
      ..sort();
    return assets;
  }

  String _resolveModelSrc(String path) {
    if (path.startsWith('assets/') ||
        path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }
    return 'file://$path';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    _modelPathController.dispose();
    _descriptionController.dispose();
    _dimensionsController.dispose();
    _materialController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickModelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final ext = path.split('.').last.toLowerCase();
        if (ext != 'glb' && ext != 'gltf') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('กรุณาเลือกไฟล์โมเดล 3D นามสกุล .glb หรือ .gltf เท่านั้น')),
            );
          }
          return;
        }
        setState(() {
          _modelPathController.text = path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เลือกโมเดล: ${result.files.single.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เลือกไฟล์ไม่สำเร็จ: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _imageController.text = result.files.single.path!;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เลือกรูปภาพ: ${result.files.single.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เลือกไฟล์รูปไม่สำเร็จ: $e')),
        );
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกหมวดหมู่อย่างน้อย 1 หมวดหมู่')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final provider = context.read<FurnitureProvider>();

    final updated = Furniture(
      name: _nameController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      categories: _selectedCategories.toList(),
      price: price,
      image: _imageController.text.trim(),
      modelPath: _modelPathController.text.trim(),
      rating: widget.furniture?.rating ?? 4.8,
      soldCount: widget.furniture?.soldCount ?? 0,
      description: _descriptionController.text.trim(),
      dimensions: _dimensionsController.text.trim(),
      material: _materialController.text.trim(),
      weight: _weightController.text.trim(),
    );

    if (isEditing) {
      provider.updateFurniture(widget.furniture!.name, updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('อัปเดตข้อมูล "${updated.name}" เรียบร้อยแล้ว')),
      );
    } else {
      provider.addFurniture(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เพิ่มสินค้า "${updated.name}" สำเร็จ')),
      );
    }

    context.pop();
  }

  void _promptAddCategory(BuildContext context) {
    final newCatController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        title: Text("เพิ่มหมวดหมู่ใหม่", style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("กรอกชื่อหมวดหมู่ที่ต้องการเพิ่มในระบบ", style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: newCatController,
              autofocus: true,
              style: TextStyle(color: AppColors.getTextPrimary(context)),
              decoration: InputDecoration(
                hintText: "เช่น Outdoor, Gaming, Ergonomic",
                hintStyle: TextStyle(color: AppColors.getTextSecondary(context).withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.getSurface(context),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("ยกเลิก", style: TextStyle(color: AppColors.getTextSecondary(context))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              final cat = newCatController.text.trim();
              if (cat.isNotEmpty) {
                context.read<FurnitureProvider>().addCategory(cat);
                setState(() {
                  _selectedCategories.add(cat);
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('เพิ่มและเลือกหมวดหมู่ "$cat" เรียบร้อยแล้ว')),
                );
              }
            },
            child: const Text("เพิ่มหมวดหมู่"),
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
            isEditing ? "แก้ไขสินค้า (Admin)" : "เพิ่มสินค้าใหม่ (Admin)",
            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.getTextPrimary(context)),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("ข้อมูลทั่วไป"),
                _buildTextField(
                  label: "ชื่อสินค้า *",
                  hint: "กรอกชื่อสินค้า เช่น Cozy Sofa, Executive Chair",
                  controller: _nameController,
                  validator: (v) => v == null || v.trim().isEmpty ? "กรุณากรอกชื่อสินค้า" : null,
                ),
                _buildTextField(
                  label: "คำโปรย (Subtitle)",
                  hint: "เช่น High Quality Furniture",
                  controller: _subtitleController,
                ),
                _buildMultiCategorySelector(),
                _buildTextField(
                  label: "ราคา (บาท) *",
                  hint: "เช่น 4500",
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "กรุณากรอกราคา";
                    if (double.tryParse(v) == null) return "กรุณากรอกตัวเลขจำนวนเงินที่ถูกต้อง";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("สื่อและโมเดล 3D"),
                _buildModelSelector(),
                _buildImageSelector(),
                const SizedBox(height: 20),
                _buildSectionTitle("รายละเอียดและสเปกสินค้า"),
                _buildTextField(
                  label: "คำอธิบายสินค้า",
                  hint: "รายละเอียดสินค้าเพิ่มเติม...",
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                _buildTextField(
                  label: "ขนาด (Dimensions)",
                  hint: "เช่น 60 x 60 x 80 cm",
                  controller: _dimensionsController,
                ),
                _buildTextField(
                  label: "วัสดุ (Material)",
                  hint: "เช่น Wood, Fabric, Leather",
                  controller: _materialController,
                ),
                _buildTextField(
                  label: "น้ำหนัก (Weight)",
                  hint: "เช่น 12 kg",
                  controller: _weightController,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      isEditing ? "บันทึกการแก้ไข" : "เพิ่มสินค้าลงในคลัง",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.getTextPrimary(context),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
            decoration: InputDecoration(
              hintText: hint ?? label.replaceAll('*', '').trim(),
              hintStyle: TextStyle(color: AppColors.getTextSecondary(context).withValues(alpha: 0.5), fontSize: 14),
              filled: true,
              fillColor: AppColors.getSurface(context).withValues(alpha: 0.8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiCategorySelector() {
    final categories = context.watch<FurnitureProvider>().editableCategories;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "หมวดหมู่สินค้า * (เลือกได้หลายหมวดหมู่):",
                style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () => _promptAddCategory(context),
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      "เพิ่มหมวดหมู่",
                      style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...categories.map((cat) {
                  final isSelected = _selectedCategories.contains(cat);
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    backgroundColor: AppColors.getCard(context),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.getTextPrimary(context),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(cat);
                        } else {
                          _selectedCategories.remove(cat);
                        }
                      });
                    },
                  );
                }),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: const Text("เพิ่มใหม่"),
                  backgroundColor: AppColors.getCard(context),
                  labelStyle: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                  onPressed: () => _promptAddCategory(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Path โมเดล 3D (.glb) *",
                style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              ElevatedButton.icon(
                onPressed: _pickModelFile,
                icon: const Icon(Icons.folder_open_rounded, size: 16),
                label: const Text("เลือกไฟล์จากเครื่อง", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _modelPathController,
            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
            validator: (v) => v == null || v.trim().isEmpty ? "กรุณาระบุไฟล์โมเดล 3D" : null,
            decoration: InputDecoration(
              hintText: "assets/furniture_models/Chair.glb หรือ path ไฟล์ในเครื่อง/URL",
              hintStyle: TextStyle(color: AppColors.getTextSecondary(context).withValues(alpha: 0.5), fontSize: 13),
              filled: true,
              fillColor: AppColors.getSurface(context).withValues(alpha: 0.8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "หรือเลือกโมเดลที่มีอยู่แล้ว (Presets):",
            style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FutureBuilder<List<String>>(
              future: _presetModelsFuture,
              builder: (context, snapshot) {
                final models = snapshot.data ?? const <String>[];
                if (snapshot.connectionState != ConnectionState.done) {
                  return Text(
                    "กำลังโหลดโมเดล...",
                    style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 14),
                  );
                }
                if (models.isEmpty) {
                  return Text(
                    "ไม่พบโมเดลใน assets/furniture_models",
                    style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 14),
                  );
                }
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: models.contains(_modelPathController.text) ? _modelPathController.text : null,
                    hint: Text("เลือกโมเดลที่มีในระบบ", style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 14)),
                    dropdownColor: AppColors.getCard(context),
                    items: models.map((model) {
                      final filename = model.split('/').last;
                      return DropdownMenuItem(
                        value: model,
                        child: Text(filename, style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _modelPathController.text = value;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "ตัวอย่างโมเดล",
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 260,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.getSurface(context).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _modelPathController.text.trim().isEmpty
                ? Center(
                    child: Text(
                      "เลือกโมเดลเพื่อดูตัวอย่าง",
                      style: TextStyle(color: AppColors.getTextSecondary(context)),
                    ),
                  )
                : ModelViewer(
                    key: ValueKey(_modelPathController.text.trim()),
                    src: _resolveModelSrc(_modelPathController.text.trim()),
                    alt: _nameController.text.trim().isEmpty
                        ? "ตัวอย่างโมเดลสินค้า"
                        : _nameController.text.trim(),
                    autoRotate: true,
                    cameraControls: true,
                    backgroundColor: Colors.transparent,
                    ar: false,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Path รูปภาพตัวอย่าง *",
                style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              ElevatedButton.icon(
                onPressed: _pickImageFile,
                icon: const Icon(Icons.image_outlined, size: 16),
                label: const Text("เลือกรูปจากเครื่อง", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _imageController,
            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
            validator: (v) => v == null || v.trim().isEmpty ? "กรุณาระบุไฟล์รูปภาพ" : null,
            decoration: InputDecoration(
              hintText: "assets/images/furniture/Chair.webp หรือ path ไฟล์ในเครื่อง/URL",
              hintStyle: TextStyle(color: AppColors.getTextSecondary(context).withValues(alpha: 0.5), fontSize: 13),
              filled: true,
              fillColor: AppColors.getSurface(context).withValues(alpha: 0.8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "หรือเลือกรูปภาพที่มีอยู่แล้ว (Presets):",
            style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FutureBuilder<List<String>>(
              future: _presetImagesFuture,
              builder: (context, snapshot) {
                final images = snapshot.data ?? const <String>[];
                if (snapshot.connectionState != ConnectionState.done) {
                  return Text(
                    "กำลังโหลดรูปภาพ...",
                    style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 14),
                  );
                }
                if (images.isEmpty) {
                  return Text(
                    "ยังไม่มีรูปภาพใน assets/images/furniture",
                    style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 14),
                  );
                }
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: images.contains(_imageController.text) ? _imageController.text : null,
                    hint: Text("เลือกรูปภาพที่มีในระบบ", style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 14)),
                    dropdownColor: AppColors.getCard(context),
                    items: images.map((image) {
                      final filename = image.split('/').last;
                      return DropdownMenuItem(
                        value: image,
                        child: Text(filename, style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _imageController.text = value;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Image Preview
          if (_imageController.text.isNotEmpty)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.getSurface(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageWidget(_imageController.text),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 40));
    } else if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 40));
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chair, size: 40));
      }
      return const Icon(Icons.chair, size: 40);
    }
  }
}
