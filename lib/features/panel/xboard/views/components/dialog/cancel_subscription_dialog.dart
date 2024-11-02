// lib/features/panel/xboard/views/components/dialog/cancel_subscription_dialog.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/core/localization/translations.dart';
import '../../../services/http_service/user_service.dart';
import '../../../utils/storage/token_storage.dart';
import '../../../models/user_info_model.dart';

class CancelSubscriptionDialog extends ConsumerStatefulWidget {
  final UserInfo userInfo;
  final Function()? onCancelled;

  const CancelSubscriptionDialog({
    super.key,
    required this.userInfo,
    this.onCancelled,
  });

  @override
  _CancelSubscriptionDialogState createState() => _CancelSubscriptionDialogState();
}

class _CancelSubscriptionDialogState extends ConsumerState<CancelSubscriptionDialog> {
  bool _isLoading = false;
  String? _selectedReason;
  final _feedbackController = TextEditingController();
  bool _confirmed = false;

  final List<String> _cancelReasons = [
    'too_expensive',
    'not_using',
    'technical_issues',
    'found_alternative',
    'temporary_pause',
    'other'
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  String _getReasonText(String reason, Translations t) {
    switch (reason) {
      case 'too_expensive':
        return t.subscription.cancelReasons.tooExpensive;
      case 'not_using':
        return t.subscription.cancelReasons.notUsing;
      case 'technical_issues':
        return t.subscription.cancelReasons.technicalIssues;
      case 'found_alternative':
        return t.subscription.cancelReasons.foundAlternative;
      case 'temporary_pause':
        return t.subscription.cancelReasons.temporaryPause;
      case 'other':
        return t.subscription.cancelReasons.other;
      default:
        return reason;
    }
  }

  Future<void> _handleCancelSubscription() async {
    if (_selectedReason == null || !_confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final accessToken = await getToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // 创建取消请求数据
      final cancelData = {
        'subscription_id': widget.userInfo.currentSubscriptionId,
        'reason': _selectedReason,
        'feedback': _feedbackController.text.trim(),
        'confirmed': _confirmed,
      };

      // 发送取消请求
      await UserService().cancelSubscription(
        accessToken,
        widget.userInfo.currentSubscriptionId!,
        cancelData,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        widget.onCancelled?.call();

        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(translationsProvider).subscription.cancelSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ref.read(translationsProvider).subscription.cancelError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题
              Text(
                t.subscription.cancelTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 警告信息
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade700,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.subscription.cancelWarning,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 取消原因
              Text(
                t.subscription.cancelReason,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _cancelReasons.length,
                (index) => RadioListTile<String>(
                  title: Text(_getReasonText(_cancelReasons[index], t)),
                  value: _cancelReasons[index],
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 16),

              // 反馈文本框
              if (_selectedReason != null) ...[
                Text(
                  t.subscription.additionalFeedback,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _feedbackController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: t.subscription.feedbackHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 确认复选框
              CheckboxListTile(
                value: _confirmed,
                onChanged: (value) {
                  setState(() {
                    _confirmed = value ?? false;
                  });
                },
                title: Text(t.subscription.confirmCancel),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(t.general.cancel),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading || !_confirmed || _selectedReason == null
                        ? null
                        : _handleCancelSubscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(t.subscription.confirmCancelButton),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 使用方式示例：
void showCancelSubscriptionDialog(BuildContext context, UserInfo userInfo) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => CancelSubscriptionDialog(
      userInfo: userInfo,
      onCancelled: () {
        // 处理取消订阅后的操作
      },
    ),
  );
}