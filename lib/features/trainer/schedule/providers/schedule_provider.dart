import 'package:flutter/foundation.dart';
import '../../../../core/network/api.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

enum ScheduleStatus { idle, loading, loaded, error }

class ScheduleProvider extends ChangeNotifier {
  final ScheduleService _service = ScheduleService();

  ScheduleStatus _status = ScheduleStatus.idle;
  String _error = '';
  List<DayBooking> _allBookings = []; // upcoming + pending merged
  DateTime _selectedDate = DateTime.now();
  String? _trainerId;

  ScheduleStatus get status => _status;
  String get error => _error;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _status == ScheduleStatus.loading;

  /// Bookings cho ngày được chọn
  List<DayBooking> get bookingsForSelectedDate {
    final dateStr = _dateKey(_selectedDate);
    return _allBookings
        .where((b) => b.bookingDate == dateStr)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Các ngày có booking (để highlight trên week strip)
  Set<String> get datesWithBookings =>
      _allBookings.map((b) => b.bookingDate).toSet();

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> load(String trainerId) async {
    _trainerId = trainerId;
    _status = ScheduleStatus.loading;
    _error = '';
    notifyListeners();
    try {
      // Load song song cả pending lẫn upcoming để có đủ dữ liệu
      final results = await Future.wait([
        _service.getPendingBookings(trainerId),   // PENDING — cần nút xác nhận
        _service.getUpcomingBookings(trainerId),  // CONFIRMED sắp tới
      ]);
      final pending  = results[0] as List<DayBooking>;
      final upcoming = results[1] as List<DayBooking>;

      // Merge, deduplicate by bookingId — pending ưu tiên (giữ status PENDING)
      final map = <String, DayBooking>{};
      for (final b in upcoming) map[b.bookingId] = b;
      for (final b in pending)  map[b.bookingId] = b; // override nếu trùng
      _allBookings = map.values.toList();
      _status = ScheduleStatus.loaded;

      // Nếu ngày đang chọn không có booking, tự nhảy về ngày gần nhất có booking
      if (bookingsForSelectedDate.isEmpty && _allBookings.isNotEmpty) {
        final sorted = _allBookings.toList()
          ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
        final firstDate = sorted.first.bookingDate; // "YYYY-MM-DD"
        final parts = firstDate.split('-');
        if (parts.length == 3) {
          _selectedDate = DateTime(
              int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      }
    } catch (e) {
      _error  = Api.parseError(e);
      _status = ScheduleStatus.error;
    }
    notifyListeners();
  }

  Future<void> acceptBooking(String bookingId) async {
    if (_trainerId == null) return;
    try {
      await _service.acceptBooking(_trainerId!, bookingId);
      await load(_trainerId!); // reload
    } catch (e) {
      _error = Api.parseError(e);
      notifyListeners();
    }
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
