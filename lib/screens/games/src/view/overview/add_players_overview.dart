import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:padly/constants.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';
import 'package:provider/provider.dart';

import '../../../../user_info/src/domain/padly_user.dart';
import 'add_players_viewmodel.dart';

class AddPlayersOverview extends StatelessWidget {
  final int maxPlayers;
  final List<PadlyUser> initialPlayers;
  final UserService userService;

  const AddPlayersOverview({
    required this.maxPlayers,
    required this.initialPlayers,
    required this.userService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddPlayersViewModel(
        maxPlayers: maxPlayers,
        initialPlayers: initialPlayers,
        userService: userService,
      ),
      child: const _AddPlayersBody(),
    );
  }
}

class _AddPlayersBody extends StatefulWidget {
  const _AddPlayersBody();

  @override
  State<_AddPlayersBody> createState() => _AddPlayersBodyState();
}

class _AddPlayersBodyState extends State<_AddPlayersBody> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<AddPlayersViewModel>().addListener(_onVmChanged);
  }

  void _onVmChanged() {
    final vm = context.read<AddPlayersViewModel>();
    if (vm.feedbackMessage != null && mounted) {
      final message = vm.feedbackMessage!;
      vm.clearFeedbackMessage();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      });
    }
  }

  @override
  void dispose() {
    context.read<AddPlayersViewModel>().removeListener(_onVmChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddPlayersViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voeg Speler Toe'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: CustomScrollView(
        slivers: [
          /// 🔍 Search field + label
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextInputField(
                    label: "Zoek speler",
                    onChanged: vm.setSearch,
                  ),
                ],
              ),
            ),
          ),

          /// ✅ Selected players
          if (vm.selectedPlayers.isNotEmpty && !vm.isSearching) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Text(
                  'Toegevoegd',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = vm.selectedPlayers[index];
                  return RequestCard(
                    user: user,
                    isSelected: true,
                    onTap: () => vm.togglePlayer(user),
                  );
                },
                childCount: vm.selectedPlayers.length,
              ),
            ),
          ],
          
          /// 📋 Results list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final users =
                    vm.isSearching ? vm.searchResults : vm.recentPlayers;
                final user = users[index];

                return RequestCard(
                  user: user,
                  isSelected: vm.isSelected(user),
                  onTap: () => vm.togglePlayer(user),
                );
              },
              childCount: vm.isSearching
                  ? vm.searchResults.length
                  : vm.recentPlayers.length,
            ),
          ),

          /// Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: defaultPadding),
          ),
        ],
      ),
    );
  }
}
/*class AddPlayersOverview extends StatelessWidget {
  final int maxPlayers;
  final List<PadlyUser> initialPlayers;
  final UserService userService;

  AddPlayersOverview({
    required this.maxPlayers,
    required this.initialPlayers,
    required this.userService,
    super.key,
  });

  final requests = [
    PadlyUser(
      firstName: "Simon",
      rank: 'P300',
    ),
    PadlyUser(
      firstName: "Charlotte",
      rank: 'P300',
      imageUrl: 'https://i.pravatar.cc/300?v=2',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
      imageUrl: 'https://i.pravatar.cc/300?v=3',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
    ),
    PadlyUser(
      firstName: "Josephine",
      rank: 'P300',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddPlayersViewModel>();

    return ChangeNotifierProvider(
      create: (_) => AddPlayersViewModel(
        maxPlayers: maxPlayers,
        initialPlayers: initialPlayers,
        userService: context.read<UserService>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Voeg Speler Toe',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          centerTitle: true,
          forceMaterialTransparency: true,
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextInputField(
                    label: "Zoek speler",
                    onChanged: (value) {
                      context.read<AddPlayersViewModel>().setSearch(value);
                    },
                  ),
                  const SizedBox(height: defaultPadding),
                  const Text(
                    'Suggesties:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            if (vm.selectedPlayers.isNotEmpty) ...[
              const SizedBox(height: defaultPadding),
              const Text('Toegevoegd',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...vm.selectedPlayers.map(
                (user) => RequestCard(
                  user: user,
                  isSelected: true,
                  onTap: () => vm.togglePlayer(user),
                ),
              ),
            ],
            if (!vm.isSearching && vm.recentPlayers.isNotEmpty) ...[
              const SizedBox(height: defaultPadding),
              const Text('Recent',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...vm.recentPlayers.map(
                (user) => RequestCard(
                  user: user,
                  isSelected: vm.isSelected(user),
                  onTap: () => vm.togglePlayer(user),
                ),
              ),
            ],
            if (vm.isSearching && vm.searchResults.isNotEmpty) ...[
              Expanded(
                child: Container(
                  child: CustomScrollView(
                    slivers: [
                      SliverSafeArea(
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return RequestCard(
                                user: requests[index],
                                isSelected: Random().nextBool(),
                              );
                            },
                            childCount: requests.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: defaultPadding / 2),
          ],
        ),
      ),
    );
  }
}
*/
class RequestCard extends StatelessWidget {
  final PadlyUser user;
  final bool isSelected;
  final VoidCallback? onTap;
  const RequestCard(
      {required this.user, required this.isSelected, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final image = user.imageUrl != null
        ? NetworkImage(
            user.imageUrl!,
          )
        : null;

    return Card(
      color: isSelected ? cardFeaturedBackgroundColor : cardBackgroundColor,
      shape: RoundedRectangleBorder(
        side:
            BorderSide(color: isSelected ? primaryColor : cardBackgroundColor),
        borderRadius: BorderRadius.circular(defaultBorderRadious * 2),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding / 4,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 1,
          bottom: 1,
          left: 14,
          right: 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: onTap,
              splashColor: Colors.transparent,
              contentPadding: const EdgeInsets.all(0),
              leading: SizedBox(
                height: 36,
                width: 36,
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: pillBackgroundColor,
                  foregroundImage: image,
                  child: image == null
                      ? SvgPicture.asset(
                          "assets/icons/Profile.svg",
                          height: defaultPadding * 1.5,
                          colorFilter: const ColorFilter.mode(
                              whiteColor, BlendMode.srcIn),
                        )
                      : null,
                ),
              ),
              title: Text(
                [
                  if (user.firstName != null) user.firstName,
                  if (user.lastName != null) user.lastName,
                ].join(' '),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              /*subtitle: Row(
                children: [
                  Text(
                    'padel',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Transform(
                    transform: Matrix4.identity()..scale(0.75)
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
              ),*/
              trailing: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? primaryColor : whiteColor60,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Transform.scale(
                  scale: 0.7,
                  child: isSelected
                      ? SvgPicture.asset(
                          "assets/icons/Singlecheck.svg",
                          colorFilter: const ColorFilter.mode(
                            backgroundColor,
                            BlendMode.srcIn,
                          ),
                        )
                      : null,
                ),
              ),
            ),
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

class TextInputField extends StatelessWidget {
  final String label;
  final dynamic value;
  final ValueChanged<String> onChanged;

  const TextInputField({
    required this.label,
    this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? "",
      validator: (value) => value!.isEmpty ? "Please fill in" : null,
      onChanged: (value) {
        onChanged(value);
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: label,
      ),
    );
  }
}
