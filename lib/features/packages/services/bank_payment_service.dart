import '../../../core/network/api.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/bank_payment_models.dart';

class BankPaymentService {
  final AuthStorage _storage = AuthStorage();

  /// POST /bank-payments/create — tạo đơn thanh toán, trả về QR URL
  Future<CreateBankPaymentResponse> createPayment({
    required int packageId,
    String? promotionCode,
    int? overrideAmount,
  }) async {
    final userIdStr = await _storage.getUserId();
    if (userIdStr == null) throw Exception('Chưa đăng nhập');

    final request = CreateBankPaymentRequest(
      userId: int.parse(userIdStr),
      packageId: packageId,
      itemType: 'MEMBERSHIP',
      promotionCode: promotionCode,
      amount: overrideAmount,
    );

    final res = await Api.private.post(
      '/bank-payments/create',
      data: request.toJson(),
    );

    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return CreateBankPaymentResponse.fromJson(data);
  }

  /// GET /bank-payments/status/{content} — kiểm tra trạng thái thanh toán
  Future<PaymentStatusResponse> checkStatus(String content) async {
    final res = await Api.private.get('/bank-payments/status/$content');
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return PaymentStatusResponse.fromJson(data);
  }
}
