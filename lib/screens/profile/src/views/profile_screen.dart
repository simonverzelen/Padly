import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/components/bottom_navigation.dart';
import 'package:padly/components/list_tile/divider_list_tile.dart';
import 'package:padly/constants.dart';
import 'package:padly/providers/providers.dart';
import 'package:padly/route/screen_export.dart';
import 'package:padly/screens/auth/domain/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with WidgetsBindingObserver {
  bool _notificationsEnabled = false;
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final notifSettings =
        await FirebaseMessaging.instance.getNotificationSettings();
    final notifEnabled =
        notifSettings.authorizationStatus == AuthorizationStatus.authorized;
    final locEnabled = await Permission.location.isGranted;
    if (mounted) {
      setState(() {
        _notificationsEnabled = notifEnabled;
        _locationEnabled = locEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final User? firebaseUser = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: Image.asset(
          "assets/images/playzi-logo.png",
          height: 36,
          fit: BoxFit.contain,
        ),
      ),
      body: ListView(
        children: [
          ProfileCard(
            name: user?.firstName ?? "",
            email: firebaseUser?.email ?? "",
            imageSrc: user?.imageUrl ?? "",
            press: () {
              Navigator.pushNamed(context, userInfoScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Personalization",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          DividerListTileWithTrilingText(
            icon: LucideIcons.bell,
            title: "Notification",
            trilingText: _notificationsEnabled ? 'Aan' : 'Uit',
            press: () {
              Navigator.pushNamed(context, notificationsScreenRoute);
            },
          ),
          DividerListTileWithTrilingText(
            icon: LucideIcons.mapPin,
            title: "Location",
            trilingText: _locationEnabled ? 'Aan' : 'Uit',
            press: () {
              Navigator.pushNamed(context, locationPermissionScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Preferences",
            icon: LucideIcons.settings2,
            press: () {
              Navigator.pushNamed(context, preferencesScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Settings",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Language",
            icon: LucideIcons.globe,
            press: () {
              Navigator.pushNamed(context, selectLanguageScreenRoute);
            },
          ),
          const SizedBox(height: defaultPadding),

          // Log Out
          ListTile(
            onTap: () {
              authService.signout(context: context);
            },
            minLeadingWidth: 24,
            leading: const Icon(
              LucideIcons.logOut,
              size: 24,
              color: errorColor,
            ),
            title: const Text(
              "Log Out",
              style: TextStyle(color: errorColor, fontSize: 14, height: 1),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(index: 2),
    );
  }
}
