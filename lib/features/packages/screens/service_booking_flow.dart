import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../core/network/api.dart';
import '../../../core/network/app_navigator.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/gym_service_model.dart';
import '../models/service_registration_models.dart';
import '../models/bank_payment_models.dart';
import '../services/service_registration_api.dart';
import '../services/bank_payment_service.dart';
import 'bank_payment_screen.dart';

/// Luồng đăng ký dịch vụ: Chọn Trainer → Chọn Lịch → Thanh toán
class ServiceBookingFlow extends StatefulWidget {
  final GymService service;
  final VoidCallback? onSuccess;

  const ServiceBookingFlow({
    super.key,
    required this.service,
    this.onSuccess,
  });

  @override
  State<ServiceBookingFlow> createState() => _ServiceBookingFlowState();
}

class _ServiceBookingFlowState extends State<ServiceBookingFlow> {
  final _api = ServiceRegistrationApi();
  final _bankService = BankPaymentService();
  final _storage = AuthStorage();

  int _step = 0; // 0=trainer, 1=schedule, 2=payment
  static const _steps = ['Chọn HLV', 'Chọn lịch', 'Thanh toán'];

  // Step 1
  List<TrainerForBooking> _trainers = [];
  bool _loadingTrainers = true;
  TrainerForBooking? _selectedTrainer;

  // Step 2
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeSlot? _selectedSlot;

  // Step 3 — loading state
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    try {
      final list = await _api.getTrainersByService(widget.service.id);
      if (mounted) setState(() => _trainers = list);
    } catch (_) {
      // Không có trainer — vẫn cho tiếp tục (admin sẽ assign)
    } finally {
      if (mounted) setState(() => _loadingTrainers = false);
    }
  }

  void _next() {
    if (_step == 1 && _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khung giờ tập')),
      );
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  String get _bookingDateStr =>
      '${_selectedDate.year}-'
      '${_selectedDate.month.toString().padLeft(2, '0')}-'
      '${_selectedDate.day.toString().padLeft(2, '0')}';

  // Có đủ dữ liệu để tạo booking (bắt buộc phải có slot, trainer là optional)
  bool get _hasSlot => _selectedSlot != null;
  bool get _hasTrainer => _selectedTrainer != null;

  // ── Thanh toán VietQR ────────────────────────────────────────────────────
  // Luồng đúng theo web:
  //   1. registerService(ONLINE) → lấy registrationId (PENDING)
  //   2. Tạo QR bank payment (gắn registrationId)
  //   3. Sau khi webhook kích hoạt → tìm registration ACTIVE → createBooking
  Future<void> _payByBank() async {
    setState(() => _processing = true);
    try {
      // Bước 1: Tạo registration ONLINE (PENDING — chờ webhook kích hoạt)
      final reg = await _api.registerService(
        serviceId: widget.service.id,
        registrationType: 'ONLINE',
        notes: _hasTrainer
            ? 'Trainer mong muốn: ${_selectedTrainer!.fullName} | ${_selectedSlot?.label ?? ''} | $_bookingDateStr'
            : null,
      );

      // Bước 2: Tạo QR bank payment, gắn registrationId để webhook match đúng
      final userIdStr = await _storage.getUserId();
      final userId = int.parse(userIdStr!);
      final res = await Api.private.post('/bank-payments/create', data: {
        'userId': userId,
        'serviceId': widget.service.id,
        'itemType': 'SERVICE',
        // Gửi registrationId để BankPaymentService link đúng registration
        'registrationId': reg.id,
      });
      final data =
          (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final paymentData = CreateBankPaymentResponse.fromJson(data);

      if (!mounted) return;
      Navigator.pop(context); // đóng flow

      // Bước 3: Mở màn hình QR — sau khi thanh toán thành công, tạo booking
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BankPaymentScreen(
            paymentData: paymentData,
            packageName: widget.service.name,
            onSuccess: () async {
              Navigator.pop(context); // đóng QR screen

              // Tạo booking nếu user đã chọn lịch (trainer optional)
              if (_hasSlot) {
                try {
                  // Tìm registration vừa được webhook kích hoạt
                  final activeReg = await _api.findActiveRegistration(
                      widget.service.id, reg.id);
                  if (activeReg != null) {
                    await _api.createBooking(
                      serviceRegistrationId: activeReg.id,
                      trainerId: _selectedTrainer?.id, // null = admin assign sau
                      bookingDate: _bookingDateStr,
                      startTime: _selectedSlot!.startTime,
                      endTime: _selectedSlot!.endTime,
                    );
                  }
                } catch (_) {
                  // Non-fatal — admin có thể assign sau
                }
              }

              widget.onSuccess?.call();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đăng ký "${widget.service.name}" thành công!'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(Api.parseError(e)),
              backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  // ── Thanh toán tại quầy ──────────────────────────────────────────────────
  // Luồng đúng theo web:
  //   1. registerService(COUNTER) → registrationId
  //   2. createBooking ngay (nếu có trainer+lịch) — PENDING chờ admin xác nhận
  //   3. Đóng flow, về trang gói tập
  Future<void> _payAtCounter() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thanh toán tại quầy',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Bạn sẽ đăng ký dịch vụ "${widget.service.name}" và thanh toán trực tiếp tại quầy lễ tân.\n\nXác nhận?',
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

    setState(() => _processing = true);
    try {
      // Bước 1: Tạo registration COUNTER
      final reg = await _api.registerService(
        serviceId: widget.service.id,
        registrationType: 'COUNTER',
        notes: _hasTrainer
            ? 'Trainer mong muốn: ${_selectedTrainer!.fullName} | ${_selectedSlot?.label ?? ''} | $_bookingDateStr'
            : 'Đăng ký qua app — thanh toán tại quầy',
      );

      // Bước 2: Tạo booking ngay nếu có lịch (trainer optional — PENDING chờ admin xác nhận)
      if (_hasSlot) {
        try {
          await _api.createBooking(
            serviceRegistrationId: reg.id,
            trainerId: _selectedTrainer?.id, // null = admin assign sau
            bookingDate: _bookingDateStr,
            startTime: _selectedSlot!.startTime,
            endTime: _selectedSlot!.endTime,
          );
        } catch (_) {
          // Non-fatal — admin có thể assign sau khi xác nhận thanh toán
        }
      }

      if (!mounted) return;
      widget.onSuccess?.call();

      // Đóng hết về trang gói tập
      Navigator.popUntil(context, (route) => route.isFirst);

      ScaffoldMessenger.of(AppNavigator.key.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
              '✅ Đã đăng ký "${widget.service.name}". Vui lòng đến quầy để thanh toán.'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(Api.parseError(e)),
              backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.97,
      minChildSize: 0.6,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.service.name,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A202C)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Stepper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _StepIndicator(current: _step, steps: _steps),
            ),

            const Divider(height: 1),

            // Body
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: [
                  _TrainerStep(
                    trainers: _trainers,
                    loading: _loadingTrainers,
                    selected: _selectedTrainer,
                    onSelect: (t) => setState(() => _selectedTrainer = t),
                  ),
                  _ScheduleStep(
                    selectedDate: _selectedDate,
                    selectedSlot: _selectedSlot,
                    onDateChanged: (d) =>
                        setState(() => _selectedDate = d),
                    onSlotSelected: (s) =>
                        setState(() => _selectedSlot = s),
                  ),
                  _PaymentStep(
                    service: widget.service,
                    trainer: _selectedTrainer,
                    date: _selectedDate,
                    slot: _selectedSlot,
                    processing: _processing,
                    onBankPay: _payByBank,
                    onCounterPay: _payAtCounter,
                  ),
                ][_step],
              ),
            ),

            // Bottom nav
            if (_step < 2)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    children: [
                      if (_step > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _back,
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Quay lại'),
                          ),
                        ),
                      if (_step > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _step == 0 ? 'Tiếp theo' : 'Xác nhận lịch',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current;
  final List<String> steps;
  const _StepIndicator({required this.current, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIdx = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepIdx < current
                  ? AppTheme.primaryBlue
                  : const Color(0xFFE2E8F0),
            ),
          );
        }
        final idx = i ~/ 2;
        final done = idx < current;
        final active = idx == current;
        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: done || active
                    ? AppTheme.primaryBlue
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[idx],
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w400,
                color: active
                    ? AppTheme.primaryBlue
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Step 1: Chọn Trainer ─────────────────────────────────────────────────────
class _TrainerStep extends StatelessWidget {
  final List<TrainerForBooking> trainers;
  final bool loading;
  final TrainerForBooking? selected;
  final ValueChanged<TrainerForBooking?> onSelect;

  const _TrainerStep({
    required this.trainers,
    required this.loading,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bạn có thể bỏ qua bước này — Admin sẽ phân công HLV phù hợp.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF1D4ED8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (trainers.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Chưa có HLV nào. Admin sẽ phân công sau.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          )
        else
          ...trainers.map((t) => _TrainerCard(
                trainer: t,
                isSelected: selected?.id == t.id,
                onTap: () => onSelect(selected?.id == t.id ? null : t),
              )),
      ],
    );
  }
}

class _TrainerCard extends StatelessWidget {
  final TrainerForBooking trainer;
  final bool isSelected;
  final VoidCallback onTap;
  const _TrainerCard(
      {required this.trainer,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              backgroundImage: trainer.avatar != null
                  ? NetworkImage(trainer.avatar!)
                  : null,
              child: trainer.avatar == null
                  ? Text(
                      trainer.fullName.isNotEmpty
                          ? trainer.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainer.fullName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A202C)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trainer.specialtyLabels,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  if (trainer.totalExperienceYears != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${trainer.totalExperienceYears} năm kinh nghiệm',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textLight),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: AppTheme.primaryBlue, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Chọn lịch ────────────────────────────────────────────────────────
class _ScheduleStep extends StatelessWidget {
  final DateTime selectedDate;
  final TimeSlot? selectedSlot;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeSlot?> onSlotSelected;

  const _ScheduleStep({
    required this.selectedDate,
    required this.selectedSlot,
    required this.onDateChanged,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date picker
        const Text('Chọn ngày bắt đầu',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C))),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: CalendarDatePicker(
            initialDate: selectedDate,
            firstDate: now.add(const Duration(days: 1)),
            lastDate: now.add(const Duration(days: 90)),
            onDateChanged: onDateChanged,
          ),
        ),
        const SizedBox(height: 20),

        // Time slots
        const Text('Chọn khung giờ',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: kBookingSlots.map((slot) {
            final isSelected = selectedSlot?.startTime == slot.startTime;
            return GestureDetector(
              onTap: () =>
                  onSlotSelected(isSelected ? null : slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  slot.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF374151),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Step 3: Thanh toán ───────────────────────────────────────────────────────
class _PaymentStep extends StatelessWidget {
  final GymService service;
  final TrainerForBooking? trainer;
  final DateTime date;
  final TimeSlot? slot;
  final bool processing;
  final VoidCallback onBankPay;
  final VoidCallback onCounterPay;

  const _PaymentStep({
    required this.service,
    required this.trainer,
    required this.date,
    required this.slot,
    required this.processing,
    required this.onBankPay,
    required this.onCounterPay,
  });

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tóm tắt đơn
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Xác nhận đăng ký',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(service.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _SummaryRow(
                  icon: Icons.person_rounded,
                  label: 'HLV',
                  value: trainer?.fullName ?? 'Admin sẽ phân công'),
              _SummaryRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Ngày bắt đầu',
                  value: _fmtDate(date)),
              _SummaryRow(
                  icon: Icons.access_time_rounded,
                  label: 'Khung giờ',
                  value: slot?.label ?? '—'),
              const Divider(color: Colors.white24, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng thanh toán',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                  Text(service.formattedPrice,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text('Chọn phương thức thanh toán',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C))),
        const SizedBox(height: 14),

        // Chuyển khoản ngân hàng
        _PaymentOption(
          icon: Icons.account_balance_rounded,
          iconColor: const Color(0xFF1366BA),
          title: 'Chuyển khoản Ngân hàng',
          subtitle: 'Quét mã VietQR — tự động xác nhận',
          loading: processing,
          onTap: onBankPay,
        ),
        const SizedBox(height: 12),

        // Thanh toán tại quầy
        _PaymentOption(
          icon: Icons.store_rounded,
          iconColor: const Color(0xFF059669),
          title: 'Thanh toán tại quầy',
          subtitle: 'Đến quầy lễ tân để hoàn tất thanh toán',
          loading: false,
          onTap: processing ? null : onCounterPay,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback? onTap;

  const _PaymentOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
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
              child: loading
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
            if (!loading)
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
