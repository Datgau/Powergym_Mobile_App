import 'package:flutter/material.dart';
import '../models/membership_package.dart';
import '../services/bank_payment_service.dart';
import '../screens/bank_payment_screen.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/core/network/api.dart';

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
                      'Package "${widget.package.name}" registered successfully!'),
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
                const Text('Select payment method',
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
              title: 'Bank Transfer',
              subtitle: 'Scan VietQR — auto-confirmed',
              isLoading: _isLoading && _loadingMethod == 'BANK',
              disabled: _isLoading,
              onTap: _handleBankTransfer,
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
