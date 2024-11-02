// lib/features/panel/xboard/views/components/user_info/reset_subscription_button.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/features/panel/xboard/services/subscription/_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hiddify/core/localization/translations.dart';

class ResetSubscriptionButton extends ConsumerWidget {
  const ResetSubscriptionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionService = ref.watch(subscriptionServiceProvider);

    return ElevatedButton(
      onPressed: () async {
        final confirmed = await _showConfirmationDialog(context);
        if (confirmed) {
          try {
            final accessToken = await getToken();
            if (accessToken == null) {
              throw Exception('No access token found');
            }

            await subscriptionService.resetSubscription(accessToken);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Subscription reset successfully.')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to reset subscription: $e')),
            );
          }
        }
      },
      child: const Text('Reset Subscription'),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Subscription'),
            content: const Text('Are you sure you want to reset your subscription?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});
