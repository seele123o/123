// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$upgraderHash() => r'42ed1fb822dcca1044b955c9ccb89d325cdb15a7';

/// See also [upgrader].
@ProviderFor(upgrader)
final upgraderProvider = AutoDisposeProvider<Upgrader>.internal(
  upgrader,
  name: r'upgraderProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$upgraderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpgraderRef = AutoDisposeProviderRef<Upgrader>;
String _$appUpdateNotifierHash() => r'0fc8727ea9b0977c94076c1e59709211482af7dd';

/// See also [AppUpdateNotifier].
@ProviderFor(AppUpdateNotifier)
final appUpdateNotifierProvider =
    NotifierProvider<AppUpdateNotifier, AppUpdateState>.internal(
  AppUpdateNotifier.new,
  name: r'appUpdateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appUpdateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppUpdateNotifier = Notifier<AppUpdateState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
