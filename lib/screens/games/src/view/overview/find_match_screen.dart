import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:padly/constants.dart';
import 'package:provider/provider.dart';
import 'find_match_viewmodel.dart';
import 'game_card.dart';
import 'package:padly/screens/games/games.dart';

class FindMatchScreen extends StatelessWidget {
  const FindMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FindMatchViewmodel(),
      builder: (context, _) {
        final vm = context.watch<FindMatchViewmodel>();
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: SvgPicture.asset(
                "assets/icons/Arrow - Left.svg",
                height: 24,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: Text(
              "Vind een match",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          body: _buildBody(context, vm),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FindMatchViewmodel vm) {
    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(vm.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: defaultPadding),
              ElevatedButton(
                onPressed: vm.refresh,
                child: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      );
    }
    if (vm.games.isEmpty) {
      return const Center(child: Text('Geen matches gevonden'));
    }

    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: backgroundColor,
      onRefresh: vm.refresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _FilterChipsBar(vm: vm)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: defaultPadding / 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Resultaten",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SvgPicture.asset(
                    "assets/icons/Filter.svg",
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                        Colors.white, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
          ),
          SliverSafeArea(
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => GameCard(game: vm.games[index]),
                childCount: vm.games.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsBar extends StatelessWidget {
  final FindMatchViewmodel vm;
  const _FilterChipsBar({required this.vm});

  @override
  Widget build(BuildContext context) {
    final chips = [
      _FilterChip(label: vm.selectedSport, isActive: true, hasDropdown: true),
      const _FilterChip(label: 'P400'),
      const _FilterChip(label: 'Heren'),
      const _FilterChip(label: '0 - 15 km'),
      const _FilterChip(label: '21 Jan - 30 Jan'),
    ];

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding / 2,
        vertical: defaultPadding,
      ),
      decoration: BoxDecoration(
        color: scrollBackgroundColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          vertical: defaultPadding,
          horizontal: defaultPadding / 3,
        ),
        child: Row(
          children: [
            for (int i = 0; i < chips.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? defaultPadding / 1.5 : defaultPadding / 2,
                  right: i == chips.length - 1 ? defaultPadding : 0,
                ),
                child: chips[i],
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool hasDropdown;

  const _FilterChip({
    required this.label,
    this.isActive = false,
    this.hasDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: primaryColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isActive ? backgroundColor : primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? backgroundColor : primaryColor,
            ),
          ],
        ],
      ),
    );
  }
}
