// lib/features/panel/xboard/views/components/user_info/revise.dart

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/auth_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hiddify/core/localization/translations.dart';

class ReviseUserInfo extends ConsumerWidget {
  const ReviseUserInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revise User Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: TextEditingController(),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: TextEditingController(),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final success = await _submitUserInfo(context, authService);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User info updated successfully.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update user info.')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _submitUserInfo(BuildContext context, AuthService authService) async {
    try {
      final accessToken = await getToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // Example request to v2board backend
      final response = await authService.updateUserInfo(
        accessToken,
        {
          'name': 'Updated Name',
          'email': 'updated.email@example.com',
        },
      );

      if (response['status'] == 'success') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

final userInfoProvider = Provider<String>((ref) {
  return 'User Info';
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
