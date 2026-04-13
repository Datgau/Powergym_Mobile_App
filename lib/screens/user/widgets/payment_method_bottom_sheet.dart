import 'package:flutter/material.dart';
import '../../../../../models/membership_package.dart';
import '../../../../../config/theme.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  final MembershipPackage package;

  const PaymentMethodBottomSheet({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chọn phương thức',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A202C),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Thông tin Gói đang chọn
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        package.durationText,
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    package.formattedPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút thanh toán MoMo
            _PaymentOptionCard(
              title: 'Thanh toán qua MoMo',
              subtitle: 'Mở ứng dụng MoMo để quét mã',
              iconPath: 'assets/icons/momo_icon.png', // Thay bằng icon thật của bạn
              iconColor: const Color(0xFFA50064),
              iconData: Icons.account_balance_wallet,
              onTap: () {
                Navigator.pop(context);
                _processPayment(context, 'MOMO');
              },
            ),
            const SizedBox(height: 12),

            // Nút Chuyển khoản ngân hàng (VietQR)
            _PaymentOptionCard(
              title: 'Chuyển khoản Ngân hàng',
              subtitle: 'Quét mã VietQR tự động xác nhận',
              iconPath: 'assets/icons/bank_icon.png', // Thay bằng icon thật của bạn
              iconColor: const Color(0xFF1366BA),
              iconData: Icons.account_balance,
              onTap: () {
                Navigator.pop(context);
                _processPayment(context, 'BANK_TRANSFER');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hàm xử lý gọi API thanh toán
  void _processPayment(BuildContext context, String paymentMethod) {
    // TODO: Hiển thị Loading Dialog, gọi PackagesService().purchasePackage(...)
    // Nếu là MOMO -> Mở webview url MoMo hoặc DeepLink
    // Nếu là BANK_TRANSFER -> Mở màn hình hiển thị mã QR ngân hàng
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đang xử lý thanh toán $paymentMethod cho ${package.name}...')),
    );
  }
}

// Widget Nút bấm tùy chọn phương thức thanh toán
class _PaymentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconPath;
  final Color iconColor;
  final IconData iconData; // Dùng icon của Flutter nếu chưa có ảnh logo
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.iconColor,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              // Nếu bạn có file ảnh (ví dụ momo.png), dùng Image.asset thay thế Icon này nhé
              child: Icon(iconData, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}