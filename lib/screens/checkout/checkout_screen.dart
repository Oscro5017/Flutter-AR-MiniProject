import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../data/dummy_furniture.dart';
import '../../models/furniture_model.dart';

enum PaymentMethod { promptPay, creditCard, cashOnDelivery }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  PaymentMethod _paymentMethod = PaymentMethod.promptPay;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _nameController = TextEditingController(text: userProvider.userName);
    _phoneController = TextEditingController(text: "081-234-5678");
    _addressController = TextEditingController(text: "123/45 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพมหานคร 10110");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _fillSampleInfo() {
    setState(() {
      _nameController.text = "คุณสมชาย ใจดี";
      _phoneController.text = "089-876-5432";
      _addressController.text = "88/9 หมู่บ้านอารียา ถนนพหลโยธิน แขวงอนุสาวรีย์ เขตบางเขน กรุงเทพมหานคร 10220";
    });
  }

  void _processOrder() {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final selectedNames = cart.selectedItemNames;

    if (selectedNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ไม่มีสินค้าถูกเลือกสำหรับสั่งซื้อ")),
      );
      return;
    }

    final purchasedItems = selectedNames.map((name) {
      final furniture = furnitureList.firstWhere(
        (f) => f.name == name,
        orElse: () => Furniture(
          name: name,
          subtitle: '',
          categories: const ['General'],
          price: 0,
          image: '',
          modelPath: '',
          rating: 5,
        ),
      );
      return {
        'furniture': furniture,
        'qty': cart.getQuantity(name),
        'total': furniture.price * cart.getQuantity(name),
      };
    }).toList();

    final subtotal = cart.selectedTotalPrice;
    final shippingFee = subtotal >= 10000 ? 0.0 : 150.0;
    final grandTotal = subtotal + shippingFee;

    final orderData = {
      'orderId': 'AR-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${const Uuid().v4().substring(0, 4).toUpperCase()}',
      'date': DateTime.now().toString().split('.')[0],
      'recipientName': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'paymentMethod': _paymentMethod == PaymentMethod.promptPay
          ? 'PromptPay'
          : (_paymentMethod == PaymentMethod.creditCard ? 'Credit Card' : 'Cash on Delivery (COD)'),
      'items': purchasedItems,
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'grandTotal': grandTotal,
    };

    // Remove purchased items from cart
    cart.removeSelectedFromCart();

    // Navigate to Receipt screen with order data
    context.push('/receipt', extra: orderData);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final selectedNames = cart.selectedItemNames;

    final items = selectedNames.map((name) {
      final furniture = furnitureList.firstWhere((f) => f.name == name);
      final qty = cart.getQuantity(name);
      return {'furniture': furniture, 'qty': qty};
    }).toList();

    final subtotal = cart.selectedTotalPrice;
    final shippingFee = subtotal >= 10000 ? 0.0 : 150.0;
    final grandTotal = subtotal + shippingFee;

    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("ชำระเงิน (Checkout)", style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
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
                _buildOrderItemsSection(context, items),
                const SizedBox(height: 24),
                _buildAddressSection(context),
                const SizedBox(height: 24),
                _buildPaymentSection(context, grandTotal),
                const SizedBox(height: 24),
                _buildPriceSummarySection(context, subtotal, shippingFee, grandTotal),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _processOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      "ยืนยันสั่งซื้อ (฿${grandTotal.toInt()})",
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

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection(BuildContext context, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, "รายการสินค้าที่จะสั่งซื้อ (${items.length} รายการ)", Icons.shopping_bag_outlined),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getSurface(context).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: items.map((item) {
              final f = item['furniture'] as Furniture;
              final qty = item['qty'] as int;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text("• ", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        f.name,
                        style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "x$qty",
                      style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "฿${(f.price * qty).toInt()}",
                      style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          "ข้อมูลที่อยู่จัดส่ง",
          Icons.location_on_outlined,
          trailing: GestureDetector(
            onTap: _fillSampleInfo,
            child: const Row(
              children: [
                Icon(Icons.bolt, color: AppColors.primary, size: 16),
                SizedBox(width: 2),
                Text("กรอกตัวอย่าง", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getSurface(context).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _buildInputLabel("ชื่อ-นามสกุล ผู้รับ *"),
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? "กรุณากรอกชื่อผู้รับ" : null,
                decoration: _buildInputDecoration("กรอกชื่อผู้รับ"),
              ),
              const SizedBox(height: 12),
              _buildInputLabel("เบอร์โทรศัพท์ติดต่อ *"),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? "กรุณากรอกเบอร์โทรศัพท์" : null,
                decoration: _buildInputDecoration("081-234-5678"),
              ),
              const SizedBox(height: 12),
              _buildInputLabel("ที่อยู่จัดส่งสินค้า *"),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
                validator: (v) => v == null || v.trim().isEmpty ? "กรุณากรอกที่อยู่จัดส่ง" : null,
                decoration: _buildInputDecoration("บ้านเลขที่ ซอย ถนน แขวง/ตำบล เขต/อำเภอ จังหวัด รหัสไปรษณีย์"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context, double totalAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, "วิธีการชำระเงินจำลอง", Icons.payment_outlined),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getSurface(context).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.promptPay,
                groupValue: _paymentMethod,
                activeColor: AppColors.primary,
                title: Text("PromptPay QR Code", style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("สแกนจ่ายผ่านแอปธนาคาร ยอด ฿${totalAmount.toInt()}", style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12)),
                secondary: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),
              if (_paymentMethod == PaymentMethod.promptPay) _buildMockPromptPayQR(context, totalAmount),
              const Divider(height: 1),
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.creditCard,
                groupValue: _paymentMethod,
                activeColor: AppColors.primary,
                title: Text("บัตรเครดิต / เดบิตจำลอง", style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("Visa / Mastercard / JCB", style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12)),
                secondary: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),
              const Divider(height: 1),
              RadioListTile<PaymentMethod>(
                value: PaymentMethod.cashOnDelivery,
                groupValue: _paymentMethod,
                activeColor: AppColors.primary,
                title: Text("เก็บเงินปลายทาง (COD)", style: TextStyle(color: AppColors.getTextPrimary(context), fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text("ชำระเงินเมื่อพนักงานส่งมอบสินค้า", style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12)),
                secondary: const Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockPromptPayQR(BuildContext context, double totalAmount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF003087), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF003087),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "Prompt Pay",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Custom Canvas Vector PromptPay QR Code Mock
          CustomPaint(
            size: const Size(140, 140),
            painter: _MockQrPainter(),
          ),
          const SizedBox(height: 12),
          Text(
            "ยอดที่ต้องชำระ: ฿${totalAmount.toInt()}",
            style: const TextStyle(color: Color(0xFF003087), fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 2),
          const Text(
            "พร้อมเพย์: 081-XXX-5678 (AR Furniture Co., Ltd.)",
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummarySection(BuildContext context, double subtotal, double shippingFee, double grandTotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildSummaryRow(context, "ยอดรวมสินค้า", "฿${subtotal.toInt()}"),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            "ค่าจัดส่ง",
            shippingFee == 0 ? "ฟรี (ส่งฟรีเมื่อซื้อครบ ฿10,000)" : "฿${shippingFee.toInt()}",
            isHighlight: shippingFee == 0,
          ),
          const Divider(height: 20),
          _buildSummaryRow(context, "ยอดชำระสุทธิ", "฿${grandTotal.toInt()}", isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isHighlight = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.getTextPrimary(context) : AppColors.getTextSecondary(context),
            fontSize: isTotal ? 16 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight
                ? Colors.green
                : (isTotal ? AppColors.primary : AppColors.getTextPrimary(context)),
            fontSize: isTotal ? 20 : 13,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          label,
          style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.getTextSecondary(context).withValues(alpha: 0.5), fontSize: 13),
      filled: true,
      fillColor: AppColors.getCard(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }
}

class _MockQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final cellWidth = size.width / 15;
    final cellHeight = size.height / 15;

    // Corner Squares
    void drawFinderPattern(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x * cellWidth, y * cellHeight, cellWidth * 4, cellHeight * 4), paint);
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH((x + 0.8) * cellWidth, (y + 0.8) * cellHeight, cellWidth * 2.4, cellHeight * 2.4), whitePaint);
      canvas.drawRect(Rect.fromLTWH((x + 1.4) * cellWidth, (y + 1.4) * cellHeight, cellWidth * 1.2, cellHeight * 1.2), paint);
    }

    drawFinderPattern(0, 0);
    drawFinderPattern(11, 0);
    drawFinderPattern(0, 11);

    // Random pattern cells to mimic QR Code
    final mockPattern = [
      [5, 1], [6, 1], [8, 1], [9, 1],
      [5, 3], [7, 3], [9, 3],
      [1, 5], [3, 5], [5, 5], [7, 5], [10, 5], [12, 5], [14, 5],
      [2, 6], [4, 6], [6, 6], [8, 6], [11, 6], [13, 6],
      [1, 7], [5, 7], [7, 7], [9, 7], [12, 7],
      [3, 8], [6, 8], [8, 8], [11, 8], [14, 8],
      [5, 9], [7, 9], [10, 9], [13, 9],
      [6, 10], [8, 10], [12, 10],
      [5, 11], [7, 11], [9, 11], [11, 11], [13, 11],
      [6, 12], [8, 12], [10, 12], [12, 12], [14, 12],
      [5, 13], [9, 13], [11, 13], [13, 13],
    ];

    for (var pos in mockPattern) {
      canvas.drawRect(Rect.fromLTWH(pos[0] * cellWidth, pos[1] * cellHeight, cellWidth * 0.9, cellHeight * 0.9), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
