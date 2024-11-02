// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $mobileWrapperRoute,
      $desktopWrapperRoute,
      $subscriptionHistoryRoute,
      $subscriptionSettingsRoute,
      $subscriptionDetailsRoute,
      $subscriptionManageRoute,
      $subscriptionPurchaseRoute,
    ];

RouteBase get $mobileWrapperRoute => GoRouteData.$route(
      path: '/mobile',
      factory: $MobileWrapperRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'intro',
          name: 'introMobile',
          factory: $IntroMobileRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'profiles',
          name: 'profilesMobile',
          factory: $ProfilesOverviewMobileRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'settings',
          name: 'settingsMobile',
          factory: $SettingsOverviewMobileRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'about',
          name: 'aboutMobile',
          factory: $AboutMobileRouteExtension._fromState,
        ),
      ],
    );

extension $MobileWrapperRouteExtension on MobileWrapperRoute {
  static MobileWrapperRoute _fromState(GoRouterState state) =>
      const MobileWrapperRoute();

  String get location => GoRouteData.$location(
        '/mobile',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $IntroMobileRouteExtension on IntroMobileRoute {
  static IntroMobileRoute _fromState(GoRouterState state) =>
      const IntroMobileRoute();

  String get location => GoRouteData.$location(
        '/mobile/intro',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ProfilesOverviewMobileRouteExtension on ProfilesOverviewMobileRoute {
  static ProfilesOverviewMobileRoute _fromState(GoRouterState state) =>
      const ProfilesOverviewMobileRoute();

  String get location => GoRouteData.$location(
        '/mobile/profiles',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SettingsOverviewMobileRouteExtension on SettingsOverviewMobileRoute {
  static SettingsOverviewMobileRoute _fromState(GoRouterState state) =>
      const SettingsOverviewMobileRoute();

  String get location => GoRouteData.$location(
        '/mobile/settings',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AboutMobileRouteExtension on AboutMobileRoute {
  static AboutMobileRoute _fromState(GoRouterState state) =>
      const AboutMobileRoute();

  String get location => GoRouteData.$location(
        '/mobile/about',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $desktopWrapperRoute => GoRouteData.$route(
      path: '/desktop',
      factory: $DesktopWrapperRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'intro',
          name: 'introDesktop',
          factory: $IntroDesktopRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'profiles',
          name: 'profilesDesktop',
          factory: $ProfilesOverviewDesktopRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'settings',
          name: 'settingsDesktop',
          factory: $SettingsOverviewDesktopRouteExtension._fromState,
        ),
        GoRouteData.$route(
          path: 'about',
          name: 'aboutDesktop',
          factory: $AboutDesktopRouteExtension._fromState,
        ),
      ],
    );

extension $DesktopWrapperRouteExtension on DesktopWrapperRoute {
  static DesktopWrapperRoute _fromState(GoRouterState state) =>
      const DesktopWrapperRoute();

  String get location => GoRouteData.$location(
        '/desktop',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $IntroDesktopRouteExtension on IntroDesktopRoute {
  static IntroDesktopRoute _fromState(GoRouterState state) =>
      const IntroDesktopRoute();

  String get location => GoRouteData.$location(
        '/desktop/intro',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ProfilesOverviewDesktopRouteExtension
    on ProfilesOverviewDesktopRoute {
  static ProfilesOverviewDesktopRoute _fromState(GoRouterState state) =>
      const ProfilesOverviewDesktopRoute();

  String get location => GoRouteData.$location(
        '/desktop/profiles',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SettingsOverviewDesktopRouteExtension
    on SettingsOverviewDesktopRoute {
  static SettingsOverviewDesktopRoute _fromState(GoRouterState state) =>
      const SettingsOverviewDesktopRoute();

  String get location => GoRouteData.$location(
        '/desktop/settings',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AboutDesktopRouteExtension on AboutDesktopRoute {
  static AboutDesktopRoute _fromState(GoRouterState state) =>
      const AboutDesktopRoute();

  String get location => GoRouteData.$location(
        '/desktop/about',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $subscriptionHistoryRoute => GoRouteData.$route(
      path: '/subscription/history',
      factory: $SubscriptionHistoryRouteExtension._fromState,
    );

extension $SubscriptionHistoryRouteExtension on SubscriptionHistoryRoute {
  static SubscriptionHistoryRoute _fromState(GoRouterState state) =>
      const SubscriptionHistoryRoute();

  String get location => GoRouteData.$location(
        '/subscription/history',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $subscriptionSettingsRoute => GoRouteData.$route(
      path: '/subscription/settings',
      factory: $SubscriptionSettingsRouteExtension._fromState,
    );

extension $SubscriptionSettingsRouteExtension on SubscriptionSettingsRoute {
  static SubscriptionSettingsRoute _fromState(GoRouterState state) =>
      const SubscriptionSettingsRoute();

  String get location => GoRouteData.$location(
        '/subscription/settings',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $subscriptionDetailsRoute => GoRouteData.$route(
      path: '/subscription/details',
      factory: $SubscriptionDetailsRouteExtension._fromState,
    );

extension $SubscriptionDetailsRouteExtension on SubscriptionDetailsRoute {
  static SubscriptionDetailsRoute _fromState(GoRouterState state) =>
      const SubscriptionDetailsRoute();

  String get location => GoRouteData.$location(
        '/subscription/details',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $subscriptionManageRoute => GoRouteData.$route(
      path: '/subscription/manage',
      factory: $SubscriptionManageRouteExtension._fromState,
    );

extension $SubscriptionManageRouteExtension on SubscriptionManageRoute {
  static SubscriptionManageRoute _fromState(GoRouterState state) =>
      const SubscriptionManageRoute();

  String get location => GoRouteData.$location(
        '/subscription/manage',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $subscriptionPurchaseRoute => GoRouteData.$route(
      path: '/subscription/purchase',
      factory: $SubscriptionPurchaseRouteExtension._fromState,
    );

extension $SubscriptionPurchaseRouteExtension on SubscriptionPurchaseRoute {
  static SubscriptionPurchaseRoute _fromState(GoRouterState state) =>
      const SubscriptionPurchaseRoute();

  String get location => GoRouteData.$location(
        '/subscription/purchase',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
