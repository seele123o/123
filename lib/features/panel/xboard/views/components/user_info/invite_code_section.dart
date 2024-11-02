// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/future_provider.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/invite_code_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InviteCodeSection extends ConsumerWidget {
  const InviteCodeSection({super.key});

  Future<void> _generateInviteCode(BuildContext context, WidgetRef ref) async {
    final t = ref.watch(translationsProvider);
    final accessToken = await getToken();
    if (accessToken == null) {
      _showSnackbar(context, t.userInfo.noAccessToken);
      return;
    }

    try {
      final success = await InviteCodeService().generateInviteCode(accessToken);
      if (success) {
        _showSnackbar(context, t.inviteCode.generateInviteCode);
        // ignore: unused_result
        ref.refresh(inviteCodesProvider);
      } else {
        _showSnackbar(context, t.inviteCode.inviteCodeGenerateError);
      }
    } catch (e) {
      _showSnackbar(context, "${t.inviteCode.inviteCodeGenerateError}: $e");
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String _formatBenefit(InviteCodeBenefit benefit) {
    switch (benefit.type) {
      case BenefitType.percentageOff:
        return '${benefit.value}% 折扣';
      case BenefitType.fixedAmount:
        return '减免 ${benefit.value}';
      case BenefitType.fixedPrice:
        return '特价 ${benefit.value}';
    }
  }

  String _getRemainingTimeText(DateTime? expiresAt) {
    if (expiresAt == null) return '永久有效';
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return '已过期';
    if (remaining.inDays > 0) {
      return '剩余 ${remaining.inDays} 天';
    }
    if (remaining.inHours > 0) {
      return '剩余 ${remaining.inHours} 小时';
    }
    return '即将过期';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.inviteCode.inviteCodeListTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _generateInviteCode(context, ref),
                  icon: const Icon(Icons.add),
                  label: Text(t.inviteCode.generateInviteCode),
                ),
              ],
            ),
            const Divider(),
            Consumer(
              builder: (context, ref, child) {
                final inviteCodesAsync = ref.watch(inviteCodesProvider);

                return inviteCodesAsync.when(
                  data: (inviteCodes) {
                    if (inviteCodes.isEmpty) {
                      return Center(child: Text(t.inviteCode.noInviteCodes));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: inviteCodes.length,
                      itemBuilder: (context, index) {
                        final inviteCode = inviteCodes[index];
                        final fullInviteLink =
                            InviteCodeService().getInviteLink(inviteCode.code);
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Icon(
                                  inviteCode.isValid
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: inviteCode.isValid
                                      ? Colors.green
                                      : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        inviteCode.code,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (inviteCode.type != InviteCodeType.standard)
                                        Text(
                                          inviteCode.type.displayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: fullInviteLink),
                                    );
                                    _showSnackbar(
                                      context,
                                      '${t.inviteCode.copiedInviteCode} $fullInviteLink',
                                    );
                                  },
                                ),
                              ],
                            ),
                            subtitle: Text(
                              _getRemainingTimeText(inviteCode.expiresAt),
                              style: TextStyle(
                                color: inviteCode.isExpiringSoon
                                    ? Colors.orange
                                    : null,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (inviteCode.benefit != null) ...[
                                      Text(
                                        '优惠信息: ${_formatBenefit(inviteCode.benefit!)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (inviteCode.benefit!.validUntil != null)
                                        Text(
                                          '优惠有效期至: ${inviteCode.benefit!.validUntil!.toString().split('.')[0]}',
                                        ),
                                    ],
                                    if (inviteCode.maxUses != null)
                                      Text(
                                        '使用次数: ${inviteCode.usedCount}/${inviteCode.maxUses}',
                                      ),
                                    Text(
                                      '创建时间: ${inviteCode.createdAt?.toString().split('.')[0] ?? '未知'}',
                                    ),
                                    if (inviteCode.isUsed)
                                      Text(
                                        '使用者: ${inviteCode.usedBy ?? '未知'}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('${t.inviteCode.fetchInviteCodesError} $error'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}