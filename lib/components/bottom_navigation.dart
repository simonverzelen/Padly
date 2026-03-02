import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:padly/constants.dart';
import 'package:padly/entry_point.dart';
import 'package:padly/route/screen_export.dart';
import 'package:padly/screens/chat/src/view/rooms/chat_screen.dart';
import 'package:padly/screens/chat/src/view/users/users_screen.dart';
import 'package:padly/screens/games/src/view/detail/create_game_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key, required this.index});
  final int index;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final List _pages = [
    EntryPoint(),
    ChatScreen(),
    CreateMatchScreen(),
    UsersScreen(),
    //HomeScreen(),
    //DiscoverScreen(),
    //BookmarkScreen(),
    // EmptyCartScreen(), // if Cart is empty
    //CartScreen(),
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
    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
            color ??
                Theme.of(context).iconTheme.color!.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 1 : 1),
            BlendMode.srcIn),
      );
    }

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
            if (index == 2) {
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
              child: svgIcon("assets/icons/Bookmark.svg", color: whiteColor),
            ),
            activeIcon: Container(
              decoration: BoxDecoration(
                color: cardFeaturedBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: svgIcon("assets/icons/Bookmark.svg", color: primaryColor),
            ),
            label: "Games",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: scrollBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: svgIcon("assets/icons/Chat.svg", color: whiteColor),
            ),
            activeIcon: Container(
              decoration: BoxDecoration(
                color: cardFeaturedBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: svgIcon("assets/icons/Chat.svg", color: primaryColor),
            ),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Container(
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(defaultPadding),
                child: SvgPicture.asset(
                  "assets/icons/Plus1.svg",
                  colorFilter:
                      const ColorFilter.mode(backgroundColor, BlendMode.srcIn),
                )),
            activeIcon: Container(
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(defaultPadding),
                child: SvgPicture.asset(
                  "assets/icons/Plus1.svg",
                  colorFilter:
                      const ColorFilter.mode(backgroundColor, BlendMode.srcIn),
                )),
            label: "New",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: scrollBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: svgIcon("assets/icons/Chat-add.svg", color: whiteColor),
            ),
            activeIcon: Container(
              decoration: BoxDecoration(
                color: cardFeaturedBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: svgIcon("assets/icons/Chat-add.svg", color: primaryColor),
            ),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: scrollBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: svgIcon("assets/icons/Profile.svg", color: whiteColor),
            ),
            activeIcon: Container(
              decoration: BoxDecoration(
                color: cardFeaturedBackgroundColor,
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(defaultPadding),
              child: svgIcon("assets/icons/Profile.svg", color: primaryColor),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
