// lib/features/panel/xboard/models/payment_model.dart
class PaymentModel {
  final String orderId;
  final double amount;
  final String? currency;
  final PaymentProvider provider;
  final PaymentStatus status;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PaymentModel({
    required this.orderId,
    required this.amount,
    this.currency,
    required this.provider,
    required this.status,
    required this.createdAt,
    this.metadata,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      orderId: json['order_id'],
      amount: json['amount'],
      currency: json['currency'],
      provider: PaymentProvider.fromString(json['provider']),
      status: PaymentStatus.fromString(json['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'amount': amount,
      'currency': currency,
      'provider': provider.toString(),
      'status': status.toString(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }
}

enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled;

  static PaymentStatus fromString(String str) {
    switch (str.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      default:
        throw ArgumentError('Invalid payment status: $str');
    }
  }
}