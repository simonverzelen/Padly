import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/core/constants.dart';
import 'package:padly/entry_point.dart';
import 'package:padly/core/route/screen_export.dart';
import 'package:padly/features/games/presentation/screens/detail/create_game_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key, required this.index});
  final int index;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final List _pages = [
    EntryPoint(),
    CreateMatchScreen(),
    ProfileScreen(),
  ];

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 68,
      borderRadius: 60,
      blur: 10,
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding * 2,
        vertical: defaultPadding,
      ),
      padding: const EdgeInsets.all(defaultPadding / 2),
      alignment: Alignment.bottomCenter,
      border: 1,
      linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardBackgroundColor,
            cardBackgroundColor,
          ],
          stops: [
            0.1,
            1,
          ]),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white38,
          scrollBackgroundColor,
          scrollBackgroundColor,
          scrollBackgroundColor,
          Colors.white38,
          scrollBackgroundColor,
        ],
      ),
      child: BottomNavigationBar(
        enableFeedback: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            if (index == 1) {
              Navigator.pushNamed(context, createGameScreenRoute);
              return;
            }
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
                pageBuilder: (context, _, __) => Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    _pages[index],
                  ],
                ),
              ),
            );
          }
        },
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: Container(
              decoration: BoxDecoration(
                color: scrollBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: const Icon(LucideIcons.layoutGrid, size: 24, color: whiteColor),
            ),
            activeIcon: Container(
              decoration: BoxDecoration(
                color: cardFeaturedBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: const Icon(LucideIcons.layoutGrid, size: 24, color: primaryColor),
            ),
            label: "Overzicht",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: const Icon(LucideIcons.plus, size: 24, color: backgroundColor),
            ),
            activeIcon: Container(
              decoration: const BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: const Icon(LucideIcons.plus, size: 24, color: backgroundColor),
            ),
            label: "Create game",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: scrollBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: const Icon(LucideIcons.user, size: 24, color: whiteColor),
            ),
            activeIcon: Container(
              decoration: BoxDecoration(
                color: cardFeaturedBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: const Icon(LucideIcons.user, size: 24, color: primaryColor),
            ),
            label: "Profiel",
          ),
        ],
      ),
    );
  }
}
