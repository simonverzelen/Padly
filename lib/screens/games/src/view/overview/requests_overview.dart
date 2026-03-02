import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:padly/components/category_button.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/route_constants.dart';

import '../../../../user_info/src/domain/padly_user.dart';

class RequestsOverview extends StatelessWidget {
  final List<PadlyUser> requests;
  RequestsOverview({required this.requests});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verzoeken',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return RequestCard(user: requests[index]);
                },
                childCount: requests.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final PadlyUser user;
  const RequestCard({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    final image = user.imageUrl != null
        ? NetworkImage(
            user.imageUrl!,
          )
        : null;

    return Card(
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding,
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, playerDetailScreenRoute),
                  child: Container(
                    padding: const EdgeInsets.all(defaultPadding / 8),
                    decoration: const BoxDecoration(
                      color: whiteColor80,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: pillBackgroundColor,
                      foregroundImage: image,
                      child: image == null
                          ? SvgPicture.asset(
                              "assets/icons/Profile.svg",
                              height: defaultPadding * 2,
                              colorFilter: const ColorFilter.mode(
                                  whiteColor, BlendMode.srcIn),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [
                          if (user.firstName != null) user.firstName,
                          if (user.lastName != null) user.lastName,
                        ].join(' '),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Text(
                            'padel',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Transform(
                            transform: Matrix4.identity()
                              ..scale(0.75)
                              ..translate(18.0, 10.0),
                            child: Chip(
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              backgroundColor: whiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side:
                                    const BorderSide(color: Colors.transparent),
                              ),
                              label: Text(
                                user.rank ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(
                                      color: backgroundColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CategoryButton(
                  text: "Weigeren",
                  isActive: false,
                  press: () {},
                ),
                const SizedBox(width: defaultPadding),
                CategoryButton(
                  text: "Accepteren",
                  isActive: true,
                  press: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class UserRequest {
  final String name;
  final String avatarUrl;
  final Map<String, String> rankings;
  final bool highlight;

  UserRequest({
    required this.name,
    required this.avatarUrl,
    required this.rankings,
    this.highlight = false,
  });
}
