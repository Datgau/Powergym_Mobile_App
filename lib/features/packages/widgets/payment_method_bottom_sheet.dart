import 'package:flutter/material.dart';
import '../models/membership_package.dart';
import '../services/bank_payment_service.dart';
import '../services/packages_service.dart';
import '../screens/bank_payment_screen.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/core/network/api.dart';
import 'package:powergym_mobile_app/core/network/app_navigator.dart';

class PaymentMethodBottomSheet extends StatefulWidget {
  final MembershipPackage package;
  final VoidCallback? onPaymentSuccess;

  const PaymentMethodBottomSheet({
    super.key,
    required this.package,
    this.onPaymentSuccess,
  });

  @override
  State<PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState
    extends State<PaymentMethodBottomSheet> {
  final BankPaymentService _bankService = BankPaymentService();
  final PackagesService _packagesService = PackagesService();
  bool _isLoading = false;
  String? _loadingMethod;

  // ── Chuyển khoản ngân hàng ───────────────────────────────────────────────
  Future<void> _handleBankTransfer() async {
    setState(() {
      _isLoading = true;
      _loadingMethod = 'BANK';
    });
    try {
      final paymentData =
          await _bankService.createPayment(packageId: widget.package.id);
      if (!mounted) return;
      Navigator.pop(context);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BankPaymentScreen(
            paymentData: paymentData,
            packageName: widget.package.name,
            onSuccess: () {
              Navigator.pop(context);
              widget.onPaymentSuccess?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Đăng ký gói "${widget.package.name}" thành công!'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(Api.parseError(e)),
            backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Thanh toán tại quầy ──────────────────────────────────────────────────
  Future<void> _handleCounter() async {
    // Bước 1: Popup xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thanh toán tại quầy',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Bạn sẽ đăng ký gói "${widget.package.name}" và thanh toán trực tiếp tại quầy lễ tân.\n\nXác nhận?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() { _isLoading = true; _loadingMethod = 'COUNTER'; });
    try {
      await _packagesService.registerCounterMembership(
        packageId: widget.package.id,
      );
      if (!mounted) return;
      widget.onPaymentSuccess?.call();

      // Đóng hết tất cả modal/bottom sheet, về lại trang gói tập
      Navigator.popUntil(context, (route) => route.isFirst);

      // Hiện snackbar thông báo
      ScaffoldMessenger.of(AppNavigator.key.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
              '✅ Đã đăng ký gói "${widget.package.name}". Vui lòng đến quầy để thanh toán.'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Api.parseError(e)), backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                      color: Color(0xFF1A202C)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed:
                      _isLoading ? null : () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Thông tin gói
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.package.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(widget.package.durationText,
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(widget.package.formattedPrice,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppTheme.primaryBlue)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Chuyển khoản ngân hàng
            _PaymentOptionCard(
              icon: Icons.account_balance_rounded,
              iconColor: const Color(0xFF1366BA),
              title: 'Chuyển khoản Ngân hàng',
              subtitle: 'Quét mã VietQR — tự động xác nhận',
              isLoading: _isLoading && _loadingMethod == 'BANK',
              disabled: _isLoading,
              onTap: _handleBankTransfer,
            ),
            const SizedBox(height: 12),

            // Thanh toán tại quầy
            _PaymentOptionCard(
              icon: Icons.store_rounded,
              iconColor: const Color(0xFF059669),
              title: 'Thanh toán tại quầy',
              subtitle: 'Đến quầy lễ tân để hoàn tất thanh toán',
              isLoading: _isLoading && _loadingMethod == 'COUNTER',
              disabled: _isLoading,
              onTap: _handleCounter,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable option card ──────────────────────────────────────────────────────
class _PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled && !isLoading ? 0.5 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onTap,
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
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: iconColor),
                      )
                    : Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ),
              if (!isLoading)
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
