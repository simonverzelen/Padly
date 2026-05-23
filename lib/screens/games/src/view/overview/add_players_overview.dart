import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/constants.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';
import 'package:provider/provider.dart';

import '../../../../user_info/src/domain/padly_user.dart';
import 'add_players_viewmodel.dart';

class AddPlayersOverview extends StatelessWidget {
  final int maxPlayers;
  final List<PadlyUser> initialPlayers;
  final UserService userService;
  final String? lockedPlayerId;

  const AddPlayersOverview({
    required this.maxPlayers,
    required this.initialPlayers,
    required this.userService,
    this.lockedPlayerId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddPlayersViewModel(
        maxPlayers: maxPlayers,
        initialPlayers: initialPlayers,
        userService: userService,
        lockedPlayerId: lockedPlayerId,
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
  AddPlayersViewModel? _vm;
  final _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_vm == null) {
      _vm = context.read<AddPlayersViewModel>();
      _vm!.addListener(_onVmChanged);
    }
  }

  void _onVmChanged() {
    final vm = _vm;
    if (vm == null || !mounted) return;
    if (vm.feedbackMessage != null) {
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
    _vm?.removeListener(_onVmChanged);
    _vm = null;
    _searchController.dispose();
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
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextInputField(
                    label: "Zoek speler",
                    controller: _searchController,
                    onChanged: vm.setSearch,
                  ),
                ],
              ),
            ),
          ),

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
                  final isLocked = user.id == vm.lockedPlayerId;
                  return RequestCard(
                    user: user,
                    isSelected: true,
                    isLocked: isLocked,
                    onTap: isLocked ? null : () => vm.togglePlayer(user),
                  );
                },
                childCount: vm.selectedPlayers.length,
              ),
            ),
          ],

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

          if (vm.isSearching && !vm.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding / 2,
                  vertical: defaultPadding / 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (vm.searchResults.isEmpty) ...[
                      const Text(
                        'Speler niet gevonden',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                    ],
                    OutlinedButton(
                      onPressed: () {
                        _searchController.clear();
                        vm.addGuestPlayer();
                      },
                      child: const Text('Voeg gastspeler toe'),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: defaultPadding),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: defaultPadding,
            horizontal: defaultPadding / 2,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
              ),
              onPressed: vm.hasChanges
                  ? () => Navigator.pop(context, vm.selectedPlayers)
                  : null,
              child: const Text('Bevestig'),
            ),
          ),
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final PadlyUser user;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback? onTap;

  const RequestCard({
    required this.user,
    required this.isSelected,
    this.isLocked = false,
    this.onTap,
    super.key,
  });

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
                      ? const Icon(LucideIcons.user, size: 24, color: whiteColor)
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
              trailing: isLocked
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Jij',
                        style: TextStyle(
                          color: backgroundColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? primaryColor : whiteColor60,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: isSelected
                          ? const Icon(LucideIcons.check, size: 18, color: backgroundColor)
                          : null,
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
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;

  const TextInputField({
    required this.label,
    this.value,
    this.controller,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? (value?.toString() ?? "") : null,
      validator: (value) => value!.isEmpty ? "Please fill in" : null,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: label,
      ),
    );
  }
}
