import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/components/category_button.dart';
import 'package:padly/constants.dart';
import 'package:padly/screens/user_info/src/domain/padly_user.dart';

class PlayerDetailScreen extends StatelessWidget {
  const PlayerDetailScreen({super.key});

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
        body: Column(
          children: [
            PlayerCard(
              user: PadlyUser(
                firstName: "Simon",
                lastName: "Verzelen",
                rank: 'P400',
                imageUrl:
                    'https://scontent-bru2-1.xx.fbcdn.net/v/t39.30808-6/274542164_10223928281048766_5075748264903147695_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=6ee11a&_nc_ohc=J1t9lQRpel4Q7kNvwG2al_x&_nc_oc=Admoi30IZ39fxUcAi5NRdDdkl63ec4BCDgYHzpRMjGQvk4GtlObOhBcm5uF7GpUEgWAqh2Qr9vFBWj44dm2cNrHB&_nc_zt=23&_nc_ht=scontent-bru2-1.xx&_nc_gid=FGxriRJTUVwOVveagB3KoA&oh=00_AfU_UuQBVrRVWYZunkTipkV3NRqDO4x_T1JOV3NhQ_JJjw&oe=68BBD900',
              ),
            ),
            const SizedBox(height: defaultPadding * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CategoryButton(
                  text: "Open Chat",
                  icon: LucideIcons.messageCircle,
                  press: () => {},
                  isActive: true,
                ),
              ],
            ),
          ],
        ));
  }
}

class PlayerCard extends StatelessWidget {
  final PadlyUser user;
  const PlayerCard({required this.user, super.key});

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(defaultPadding / 8),
              decoration: const BoxDecoration(
                color: whiteColor80,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: defaultPadding * 3,
                backgroundColor: pillBackgroundColor,
                foregroundImage: image,
                child: image == null
                    ? const Icon(LucideIcons.user, size: 32, color: whiteColor)
                    : null,
              ),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              [
                if (user.firstName != null) user.firstName,
                if (user.lastName != null) user.lastName,
              ].join(' '),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              "20 oktober 1990",
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                    backgroundColor: whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.transparent),
                    ),
                    label: Text(
                      user.rank ?? '',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
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
    );
  }
}
