import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../config/theme.dart';
import '../models/bank_payment_models.dart';
import '../services/bank_payment_service.dart';

// ── Thông tin tài khoản ngân hàng cố định ────────────────────────────────────
const _kBankCode    = 'BIDV';
const _kAccountNo   = '96247TBJCY';
const _kAccountName = 'NGUYEN TIEN DAT';

/// Màn hình hiển thị QR VietQR và tự động polling trạng thái thanh toán
class BankPaymentScreen extends StatefulWidget {
  final CreateBankPaymentResponse paymentData;
  final String packageName;
  final VoidCallback onSuccess;

  const BankPaymentScreen({
    super.key,
    required this.paymentData,
    required this.packageName,
    required this.onSuccess,
  });

  @override
  State<BankPaymentScreen> createState() => _BankPaymentScreenState();
}

class _BankPaymentScreenState extends State<BankPaymentScreen>
    with SingleTickerProviderStateMixin {
  final BankPaymentService _service = BankPaymentService();

  Timer? _pollTimer;
  Timer? _countdownTimer;
  BankPaymentStatus _status = BankPaymentStatus.pending;
  int _secondsLeft = 600;
  bool _isPolling = false;
  bool _isSavingQr = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _calcSecondsLeft();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController);
    _startPolling();
    _startCountdown();
  }

  void _calcSecondsLeft() {
    try {
      final expired = DateTime.parse(
          widget.paymentData.expiredAt.replaceAll(' ', 'T'));
      _secondsLeft =
          expired.difference(DateTime.now()).inSeconds.clamp(0, 3600);
    } catch (_) {
      _secondsLeft = 600;
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_isPolling || _status != BankPaymentStatus.pending) return;
      _isPolling = true;
      try {
        final result =
            await _service.checkStatus(widget.paymentData.content);
        if (!mounted) return;
        if (result.status != BankPaymentStatus.pending) {
          setState(() => _status = result.status);
          _stopTimers();
          if (result.status == BankPaymentStatus.completed) {
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) widget.onSuccess();
          }
        }
      } catch (_) {}
      finally {
        _isPolling = false;
      }
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _status = BankPaymentStatus.expired;
          _stopTimers();
        }
      });
    });
  }

  void _stopTimers() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.stop();
  }

  @override
  void dispose() {
    _stopTimers();
    _pulseController.dispose();
    super.dispose();
  }

  String get _countdownText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _formattedAmount {
    final formatted = widget.paymentData.amount
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '${formatted}đ';
  }

  /// Tải QR về máy rồi mở share sheet
  Future<void> _saveQrImage() async {
    if (_isSavingQr) return;
    setState(() => _isSavingQr = true);
    try {
      final response = await http.get(Uri.parse(widget.paymentData.qrUrl));
      if (response.statusCode != 200) throw Exception('Tải ảnh thất bại');

      final Uint8List bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/vietqr_payment.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text:
            'Mã QR thanh toán PowerGym\nSố tiền: $_formattedAmount\nNội dung: ${widget.paymentData.content}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải QR: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingQr = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Thanh toán VietQR'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: switch (_status) {
        BankPaymentStatus.completed =>
          _SuccessView(packageName: widget.packageName),
        BankPaymentStatus.failed =>
          _FailedView(onRetry: () => Navigator.pop(context)),
        BankPaymentStatus.expired =>
          _ExpiredView(onBack: () => Navigator.pop(context)),
        _ => _PendingView(
            paymentData: widget.paymentData,
            countdownText: _countdownText,
            formattedAmount: _formattedAmount,
            pulseAnim: _pulseAnim,
            isSavingQr: _isSavingQr,
            onSaveQr: _saveQrImage,
          ),
      },
    );
  }
}

// ── Trạng thái đang chờ ──────────────────────────────────────────────────────
class _PendingView extends StatelessWidget {
  final CreateBankPaymentResponse paymentData;
  final String countdownText;
  final String formattedAmount;
  final Animation<double> pulseAnim;
  final bool isSavingQr;
  final VoidCallback onSaveQr;

  const _PendingView({
    required this.paymentData,
    required this.countdownText,
    required this.formattedAmount,
    required this.pulseAnim,
    required this.isSavingQr,
    required this.onSaveQr,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          // ── Thông tin đơn hàng ──────────────────────────────────────────
          _InfoCard(
            amount: formattedAmount,
            countdown: countdownText,
          ),
          const SizedBox(height: 16),

          // ── QR Code + nút tải ───────────────────────────────────────────
          _QrCard(
            qrUrl: paymentData.qrUrl,
            pulseAnim: pulseAnim,
            isSavingQr: isSavingQr,
            onSaveQr: onSaveQr,
          ),
          const SizedBox(height: 16),

          // ── Thông tin chuyển khoản (số TK + nội dung) ──────────────────
          _BankInfoCard(
            content: paymentData.content,
            amount: formattedAmount,
          ),
          const SizedBox(height: 16),

          // ── Hướng dẫn ──────────────────────────────────────────────────
          const _InstructionCard(),
        ],
      ),
    );
  }
}

// ── Card thông tin đơn ───────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String amount;
  final String countdown;
  const _InfoCard({required this.amount, required this.countdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Số tiền thanh toán',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(amount,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Hết hạn sau',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(countdown,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFeatures: [FontFeature.tabularFigures()])),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Card QR + nút tải ────────────────────────────────────────────────────────
class _QrCard extends StatelessWidget {
  final String qrUrl;
  final Animation<double> pulseAnim;
  final bool isSavingQr;
  final VoidCallback onSaveQr;

  const _QrCard({
    required this.qrUrl,
    required this.pulseAnim,
    required this.isSavingQr,
    required this.onSaveQr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tiêu đề
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_2_rounded,
                  color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Quét mã QR để thanh toán',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A202C)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Dùng app ngân hàng bất kỳ hỗ trợ VietQR',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // QR Image
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.2), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                qrUrl,
                width: 230,
                height: 230,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 230,
                    height: 230,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 230,
                  height: 230,
                  child: Center(
                    child: Icon(Icons.qr_code, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nút tải QR
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isSavingQr ? null : onSaveQr,
              icon: isSavingQr
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(
                isSavingQr ? 'Đang tải...' : 'Tải QR về máy / Chia sẻ',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                side: const BorderSide(color: AppTheme.primaryBlue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Trạng thái chờ
          FadeTransition(
            opacity: pulseAnim,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFA726), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Đang chờ xác nhận thanh toán...',
                  style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFFFA726),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card thông tin ngân hàng + copy ─────────────────────────────────────────
class _BankInfoCard extends StatelessWidget {
  final String content;
  final String amount;
  const _BankInfoCard({required this.content, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_rounded,
                      size: 18, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Thông tin chuyển khoản',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A202C)),
                ),
              ],
            ),
          ),

          // Các dòng thông tin
          _CopyRow(
            label: 'Ngân hàng',
            value: _kBankCode,
            canCopy: false,
          ),
          _CopyRow(
            label: 'Số tài khoản',
            value: _kAccountNo,
            canCopy: true,
            copySnackbar: 'Đã sao chép số tài khoản',
          ),
          _CopyRow(
            label: 'Tên tài khoản',
            value: _kAccountName,
            canCopy: false,
          ),
          _CopyRow(
            label: 'Số tiền',
            value: amount,
            canCopy: true,
            copyValue: content.split(' ').last, // copy số thuần
            copySnackbar: 'Đã sao chép số tiền',
          ),
          _CopyRow(
            label: 'Nội dung CK',
            value: content,
            canCopy: true,
            copySnackbar: 'Đã sao chép nội dung chuyển khoản',
            isLast: true,
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  final String label;
  final String value;
  final bool canCopy;
  final String? copyValue;
  final String? copySnackbar;
  final bool isLast;
  final bool highlight;

  const _CopyRow({
    required this.label,
    required this.value,
    required this.canCopy,
    this.copyValue,
    this.copySnackbar,
    this.isLast = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.primaryBlue.withOpacity(0.04) : null,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(18))
            : null,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                color: highlight
                    ? AppTheme.primaryBlue
                    : const Color(0xFF1A202C),
              ),
            ),
          ),
          if (canCopy)
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: copyValue ?? value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        copySnackbar ?? 'Đã sao chép'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy_rounded,
                    size: 15, color: AppTheme.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Hướng dẫn ────────────────────────────────────────────────────────────────
class _InstructionCard extends StatelessWidget {
  const _InstructionCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('📱', 'Quét QR bằng app ngân hàng hỗ trợ VietQR'),
      ('📲', 'Hoặc: Mở app ngân hàng → Chuyển khoản → Nhập số TK BIDV bên trên'),
      ('✅', 'Kiểm tra đúng số tiền và nội dung chuyển khoản'),
      ('🔄', 'Hệ thống tự động xác nhận sau khi nhận tiền'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: Color(0xFF15803D), size: 16),
              SizedBox(width: 6),
              Text(
                'Hướng dẫn thanh toán',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$1,
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.$2,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF166534),
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trạng thái thành công ────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final String packageName;
  const _SuccessView({required this.packageName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFF15803D), size: 60),
            ),
            const SizedBox(height: 24),
            const Text('Thanh toán thành công!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A202C))),
            const SizedBox(height: 8),
            Text('Gói "$packageName" đã được kích hoạt.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ── Trạng thái thất bại ──────────────────────────────────────────────────────
class _FailedView extends StatelessWidget {
  final VoidCallback onRetry;
  const _FailedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 80),
            const SizedBox(height: 24),
            const Text('Thanh toán thất bại',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A202C))),
            const SizedBox(height: 8),
            const Text('Giao dịch không thành công. Vui lòng thử lại.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Thử lại',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trạng thái hết hạn ───────────────────────────────────────────────────────
class _ExpiredView extends StatelessWidget {
  final VoidCallback onBack;
  const _ExpiredView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer_off,
                color: Color(0xFFFFA726), size: 80),
            const SizedBox(height: 24),
            const Text('Mã QR đã hết hạn',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A202C))),
            const SizedBox(height: 8),
            const Text(
                'Vui lòng quay lại và tạo đơn thanh toán mới.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Quay lại',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
