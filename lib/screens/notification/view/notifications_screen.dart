import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/route_constants.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkNotificationStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    setState(() {
      _notificationsEnabled =
          settings.authorizationStatus == AuthorizationStatus.authorized;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/notification.jpg",
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          "Never miss a match — get notified for invites and joins.",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        const Text(
                          "Get real-time notifications when another player invites you to a match or requests to join yours.",
                        ),
                        const SizedBox(height: defaultPadding * 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadious),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/Notification.svg",
                                height: 24,
                                width: 24,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Notifications',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              CupertinoSwitch(
                                onChanged: (value) => openAppSettings(),
                                activeColor: primaryColor,
                                value: _notificationsEnabled,
                                thumbColor: primaryMaterialColor.shade900,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, selectLanguageScreenRoute);
              },
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }
}
