import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/furniture_model.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const ReceiptScreen({
    super.key,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    final orderId = orderData['orderId'] as String? ?? '#AR-20261008-0000';
    final date = orderData['date'] as String? ?? DateTime.now().toString().split('.')[0];
    final recipientName = orderData['recipientName'] as String? ?? 'คุณลูกค้า';
    final phone = orderData['phone'] as String? ?? '-';
    final address = orderData['address'] as String? ?? '-';
    final paymentMethod = orderData['paymentMethod'] as String? ?? 'PromptPay';
    final items = (orderData['items'] as List<dynamic>?) ?? [];
    final subtotal = (orderData['subtotal'] as double?) ?? 0.0;
    final shippingFee = (orderData['shippingFee'] as double?) ?? 0.0;
    final grandTotal = (orderData['grandTotal'] as double?) ?? 0.0;

    return Container(
      decoration: AppColors.backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("ใบเสร็จรับเงิน (Receipt)", style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            context.go('/home');
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSuccessBanner(context),
                const SizedBox(height: 20),
                _buildReceiptCard(
                  context,
                  orderId: orderId,
                  date: date,
                  recipientName: recipientName,
                  phone: phone,
                  address: address,
                  paymentMethod: paymentMethod,
                  items: items,
                  subtotal: subtotal,
                  shippingFee: shippingFee,
                  grandTotal: grandTotal,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go('/catalog'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("ดูสินค้าอื่นเพิ่ม", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.go('/home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text("กลับสู่หน้าหลัก", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            "🎉 สั่งซื้อสินค้าสำเร็จ!",
            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "ขอบคุณสำหรับการสั่งซื้อ ระบบได้รับคำสั่งซื้อของคุณเรียบร้อยแล้ว",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(
    BuildContext context, {
    required String orderId,
    required String date,
    required String recipientName,
    required String phone,
    required String address,
    required String paymentMethod,
    required List<dynamic> items,
    required double subtotal,
    required double shippingFee,
    required double grandTotal,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "AR Furniture Store",
                style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "ชำระเงินสำเร็จ",
                  style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow(context, "รหัสคำสั่งซื้อ:", orderId, isBold: true),
          _buildInfoRow(context, "วันที่สั่งซื้อ:", date),
          _buildInfoRow(context, "ผู้รับสินค้า:", recipientName),
          _buildInfoRow(context, "เบอร์โทรศัพท์:", phone),
          _buildInfoRow(context, "ที่อยู่จัดส่ง:", address),
          _buildInfoRow(context, "วิธีชำระเงิน:", paymentMethod),
          const Divider(height: 24),
          Text(
            "รายการสินค้า:",
            style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...items.map((itemMap) {
            final f = itemMap['furniture'] as Furniture;
            final qty = itemMap['qty'] as int;
            final itemTotal = itemMap['total'] as double;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${f.name} (x$qty)",
                      style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13),
                    ),
                  ),
                  Text(
                    "฿${itemTotal.toInt()}",
                    style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 24),
          _buildSummaryRow(context, "ราคารวมสินค้า", "฿${subtotal.toInt()}"),
          const SizedBox(height: 6),
          _buildSummaryRow(context, "ค่าจัดส่ง", shippingFee == 0 ? "ฟรี" : "฿${shippingFee.toInt()}"),
          const Divider(height: 20),
          _buildSummaryRow(context, "ยอดชำระรวมทั้งสิ้น", "฿${grandTotal.toInt()}", isGrandTotal: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: AppColors.getTextSecondary(context), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isGrandTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isGrandTotal ? AppColors.getTextPrimary(context) : AppColors.getTextSecondary(context),
            fontSize: isGrandTotal ? 15 : 13,
            fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isGrandTotal ? AppColors.primary : AppColors.getTextPrimary(context),
            fontSize: isGrandTotal ? 18 : 13,
            fontWeight: isGrandTotal ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
