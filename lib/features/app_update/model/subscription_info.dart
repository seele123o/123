import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_info.freezed.dart';

@freezed
class SubscriptionInfo with _$SubscriptionInfo {
  const SubscriptionInfo._();

  const factory SubscriptionInfo({
    required int upload,
    required int download,
    required int total,
    required DateTime expire,
    String? webPageUrl,
    String? supportUrl,
  }) = _SubscriptionInfo;

  bool get isExpired => expire.isBefore(DateTime.now());

  int get consumption => upload + download;

  double get ratio => (consumption / total).clamp(0, 1);

  Duration get remaining => expire.difference(DateTime.now());
}
