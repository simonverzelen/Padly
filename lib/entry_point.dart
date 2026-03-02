import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/screen_export.dart';
import 'package:padly/screens/games/src/view/overview/games_overview.dart';

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
            onPressed: () => showFilterBottomSheet(context),
            icon: SvgPicture.asset(
              "assets/icons/Filter.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, notificationsScreenRoute);
            },
            icon: SvgPicture.asset(
              "assets/icons/Notification.svg",
              height: 24,
              colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn),
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
          )
        ],
      ),
    );
  }
}

void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: whiteColor,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  "assets/icons/Arrow - Left.svg",
                  height: 24,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).textTheme.bodyLarge!.color!,
                      BlendMode.srcIn),
                ),
                Text(
                  'Filter',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Clear filters
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: Color(0xFF7B61FF)), // Purple
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Tabs
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ThemeData.light().outlinedButtonTheme.style,
                    onPressed: () {},
                    child: const Text("Filter"),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(defaultPadding),
                      minimumSize: const Size(double.infinity, 32),
                      side: BorderSide(width: 1.5, color: blackColor10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(defaultBorderRadious)),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: const Text("Sort",
                        style: TextStyle(color: primaryColor)),
                  ),
                )
              ],
            ),

            SizedBox(height: 24),

            // You can add actual filter list tiles here if needed later.
          ],
        ),
      );
    },
  );
}
