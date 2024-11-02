// lib/core/router/routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/app_router.dart';
import 'package:hiddify/features/common/adaptive_root_scaffold.dart';
import 'package:hiddify/features/config_option/overview/config_options_page.dart';
import 'package:hiddify/features/config_option/widget/quick_settings_modal.dart';
import 'package:hiddify/features/home/widget/home_page.dart';
import 'package:hiddify/features/intro/widget/intro_page.dart';
import 'package:hiddify/features/log/overview/logs_overview_page.dart';
import 'package:hiddify/features/panel/xboard/views/forget_password_view.dart';
import 'package:hiddify/features/panel/xboard/views/login_view.dart';
import 'package:hiddify/features/panel/xboard/views/purchase_page.dart';
import 'package:hiddify/features/panel/xboard/views/register_view.dart';
import 'package:hiddify/features/panel/xboard/views/user_info_page.dart';
import 'package:hiddify/features/panel/xboard/views/components/user_info/user_info_card.dart';
import 'package:hiddify/features/panel/xboard/views/subscription/pages/subscription_history_page.dart';
import 'package:hiddify/features/panel/xboard/views/subscription/pages/subscription_settings_page.dart';
import 'package:hiddify/features/panel/xboard/views/subscription/pages/subscription_manage_page.dart';
import 'package:hiddify/features/panel/xboard/views/subscription/pages/subscription_purchase_page.dart';
import 'package:hiddify/features/per_app_proxy/overview/per_app_proxy_page.dart';
import 'package:hiddify/features/profile/add/add_profile_modal.dart';
import 'package:hiddify/features/profile/details/profile_details_page.dart';
import 'package:hiddify/features/profile/overview/profiles_overview_page.dart';
import 'package:hiddify/features/proxy/overview/proxies_overview_page.dart';
import 'package:hiddify/features/settings/about/about_page.dart';
import 'package:hiddify/features/settings/overview/settings_overview_page.dart';
import 'package:hiddify/utils/utils.dart';

part 'routes.g.dart';

// Base Routes
class IntroRoute extends GoRouteData {
  const IntroRoute();
  static const name = "intro";

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const MaterialPage(child: IntroPage());
}

class ProfilesOverviewRoute extends GoRouteData {
  const ProfilesOverviewRoute();
  static const name = "profiles";

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const MaterialPage(child: ProfilesOverviewPage());
}

class SettingsOverviewRoute extends GoRouteData {
  const SettingsOverviewRoute();
  static const name = "settings";

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const MaterialPage(child: SettingsOverviewPage());
}

class AboutRoute extends GoRouteData {
  const AboutRoute();
  static const name = "about";

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const MaterialPage(child: AboutPage());
}

// Mobile Routes
@TypedGoRoute<MobileWrapperRoute>(
  path: "/mobile",
  routes: [
    TypedGoRoute<IntroMobileRoute>(
      path: "intro",
      name: IntroMobileRoute.name,
    ),
    TypedGoRoute<ProfilesOverviewMobileRoute>(
      path: "profiles",
      name: ProfilesOverviewMobileRoute.name,
    ),
    TypedGoRoute<SettingsOverviewMobileRoute>(
      path: "settings",
      name: SettingsOverviewMobileRoute.name,
    ),
    TypedGoRoute<AboutMobileRoute>(
      path: "about",
      name: AboutMobileRoute.name,
    ),
  ],
)
class MobileWrapperRoute extends GoRouteData {
  const MobileWrapperRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage<void>(
      key: state.pageKey,
      child: AdaptiveRootScaffold(
        navigator: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => state.extra as Widget,
              settings: settings,
            );
          },
        ),
      ),
    );
  }
}

class IntroMobileRoute extends IntroRoute {
  const IntroMobileRoute();
  static const name = "introMobile";
}

class ProfilesOverviewMobileRoute extends ProfilesOverviewRoute {
  const ProfilesOverviewMobileRoute();
  static const name = "profilesMobile";
}

class SettingsOverviewMobileRoute extends SettingsOverviewRoute {
  const SettingsOverviewMobileRoute();
  static const name = "settingsMobile";
}

class AboutMobileRoute extends AboutRoute {
  const AboutMobileRoute();
  static const name = "aboutMobile";
}

// Desktop Routes
@TypedGoRoute<DesktopWrapperRoute>(
  path: "/desktop",
  routes: [
    TypedGoRoute<IntroDesktopRoute>(
      path: "intro",
      name: IntroDesktopRoute.name,
    ),
    TypedGoRoute<ProfilesOverviewDesktopRoute>(
      path: "profiles",
      name: ProfilesOverviewDesktopRoute.name,
    ),
    TypedGoRoute<SettingsOverviewDesktopRoute>(
      path: "settings",
      name: SettingsOverviewDesktopRoute.name,
    ),
    TypedGoRoute<AboutDesktopRoute>(
      path: "about",
      name: AboutDesktopRoute.name,
    ),
  ],
)
class DesktopWrapperRoute extends GoRouteData {
  const DesktopWrapperRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return MaterialPage<void>(
      key: state.pageKey,
      child: AdaptiveRootScaffold(
        navigator: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => state.extra as Widget,
              settings: settings,
            );
          },
        ),
      ),
    );
  }
}

class IntroDesktopRoute extends IntroRoute {
  const IntroDesktopRoute();
  static const name = "introDesktop";
}

class ProfilesOverviewDesktopRoute extends ProfilesOverviewRoute {
  const ProfilesOverviewDesktopRoute();
  static const name = "profilesDesktop";
}

class SettingsOverviewDesktopRoute extends SettingsOverviewRoute {
  const SettingsOverviewDesktopRoute();
  static const name = "settingsDesktop";
}

class AboutDesktopRoute extends AboutRoute {
  const AboutDesktopRoute();
  static const name = "aboutDesktop";
}

// Subscription Routes
@TypedGoRoute<SubscriptionHistoryRoute>(
  path: "/subscription/history"
)
class SubscriptionHistoryRoute extends GoRouteData {
  const SubscriptionHistoryRoute();
  static const name = "SubscriptionHistory";

  static final GlobalKey<NavigatorState>? parentNavigatorKey = dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SubscriptionHistoryPage(),
      );
    }
    return const NoTransitionPage(
      name: name,
      child: SubscriptionHistoryPage(),
    );
  }
}

@TypedGoRoute<SubscriptionSettingsRoute>(
  path: "/subscription/settings"
)
class SubscriptionSettingsRoute extends GoRouteData {
  const SubscriptionSettingsRoute();
  static const name = "SubscriptionSettings";

  static final GlobalKey<NavigatorState>? parentNavigatorKey = dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SubscriptionSettingsPage(),
      );
    }
    return const NoTransitionPage(
      name: name,
      child: SubscriptionSettingsPage(),
    );
  }
}

@TypedGoRoute<SubscriptionDetailsRoute>(
  path: "/subscription/details"
)
class SubscriptionDetailsRoute extends GoRouteData {
  const SubscriptionDetailsRoute();
  static const name = "SubscriptionDetails";

  static final GlobalKey<NavigatorState>? parentNavigatorKey = dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SubscriptionDetailsPage(),
      );
    }
    return const NoTransitionPage(
      name: name,
      child: SubscriptionDetailsPage(),
    );
  }
}

// Management Routes
@TypedGoRoute<SubscriptionManageRoute>(
  path: "/subscription/manage"
)
class SubscriptionManageRoute extends GoRouteData {
  const SubscriptionManageRoute();
  static const name = "SubscriptionManage";

  static final GlobalKey<NavigatorState>? parentNavigatorKey = dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SubscriptionManagePage(),
      );
    }
    return const NoTransitionPage(
      name: name,
      child: SubscriptionManagePage(),
    );
  }
}

@TypedGoRoute<SubscriptionPurchaseRoute>(
  path: "/subscription/purchase"
)
class SubscriptionPurchaseRoute extends GoRouteData {
  const SubscriptionPurchaseRoute();
  static const name = "SubscriptionPurchase";

  static final GlobalKey<NavigatorState>? parentNavigatorKey = dynamicRootKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    if (useMobileRouter) {
      return const MaterialPage(
        name: name,
        child: SubscriptionPurchasePage(),
      );
    }
    return const NoTransitionPage(
      name: name,
      child: SubscriptionPurchasePage(),
    );
  }
}
