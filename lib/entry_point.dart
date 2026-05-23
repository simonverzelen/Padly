import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/route/screen_export.dart';

import 'components/bottom_navigation.dart';

class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, chatScreenRoute),
            icon: Icon(
              LucideIcons.messageCircle,
              size: 24,
              color: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, notificationsScreenRoute);
            },
            icon: Icon(
              LucideIcons.bell,
              size: 24,
              color: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
        ],
      ),
      body: const Stack(
        children: [
          GamesOverview(),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: BottomNavigation(
              index: 0,
            ),
          ),
        ],
      ),
    );
  }
}
