// Models cho Bank Payment (VietQR)

class CreateBankPaymentRequest {
  final int userId;
  final int? packageId;
  final String itemType;
  final String? promotionCode;
  final int? amount;

  const CreateBankPaymentRequest({
    required this.userId,
    this.packageId,
    this.itemType = 'MEMBERSHIP',
    this.promotionCode,
    this.amount,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        if (packageId != null) 'packageId': packageId,
        'itemType': itemType,
        if (promotionCode != null) 'promotionCode': promotionCode,
        if (amount != null) 'amount': amount,
      };
}

class CreateBankPaymentResponse {
  final String qrUrl;
  final int amount;
  final String content;
  final String expiredAt;
  final String orderId;

  const CreateBankPaymentResponse({
    required this.qrUrl,
    required this.amount,
    required this.content,
    required this.expiredAt,
    required this.orderId,
  });

  factory CreateBankPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CreateBankPaymentResponse(
      qrUrl: json['qrUrl'] as String,
      amount: (json['amount'] as num).toInt(),
      content: json['content'] as String,
      expiredAt: json['expiredAt'] as String,
      orderId: json['orderId'] as String,
    );
  }
}

enum BankPaymentStatus { pending, completed, failed, expired }

class PaymentStatusResponse {
  final BankPaymentStatus status;
  final String orderId;
  final int amount;
  final String? expiredAt;
  final String? itemType;
  final String? itemName;

  const PaymentStatusResponse({
    required this.status,
    required this.orderId,
    required this.amount,
    this.expiredAt,
    this.itemType,
    this.itemName,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] as String? ?? '').toUpperCase();
    final status = switch (rawStatus) {
      'COMPLETED' || 'SUCCESS' || 'PAID' => BankPaymentStatus.completed,
      'FAILED' || 'CANCELLED' => BankPaymentStatus.failed,
      'EXPIRED' => BankPaymentStatus.expired,
      _ => BankPaymentStatus.pending,
    };
    return PaymentStatusResponse(
      status: status,
      orderId: json['orderId'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toInt(),
      expiredAt: json['expiredAt'] as String?,
      itemType: json['itemType'] as String?,
      itemName: json['itemName'] as String?,
    );
  }
}
