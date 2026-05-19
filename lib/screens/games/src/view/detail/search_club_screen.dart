// ui/zoek_club_screen.dart
import 'package:flutter/material.dart';
import 'package:padly/constants.dart';
import 'package:provider/provider.dart';
import '../../data/google_maps_repo.dart';
import '../../data/recent_clubs_cache.dart';
import '../../domain/club.dart';
import 'search_club_viewmodel.dart';

class SearchClubScreen extends StatelessWidget {
  const SearchClubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchClubViewModel(
        GooglePlacesRepository(),
        RecentClubsCache(),
      ),
      child: const _ZoekClubView(),
    );
  }
}

class _ZoekClubView extends StatelessWidget {
  const _ZoekClubView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchClubViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selecteer club',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextInputField(
              label: 'Zoek club',
              onChanged: vm.onSearchChanged,
            ),
            const SizedBox(height: defaultPadding / 2),
            if (!vm.isSearching && vm.recentClubs.isNotEmpty)
              _RecentClubsSection(
                clubs: vm.recentClubs,
                onTap: (club) async {
                  try {
                    await vm.setToFirstRecent(club);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fout bij opslaan: $e')),
                      );
                    }
                  }
                  if (context.mounted) Navigator.pop(context, club);
                },
              ),
            if (vm.isSearching) ...[
              if (vm.filteredRecentClubs.isNotEmpty)
                _RecentClubsSection(
                  clubs: vm.filteredRecentClubs,
                  onTap: (club) => Navigator.pop(context, club),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(bottom: defaultPadding / 2),
                  child: Text(
                    'Suggesties:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text(
                      vm.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (vm.results.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ...vm.results.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: defaultPadding / 2),
                  child: LocationCard(
                    name: r.name,
                    address: r.description,
                    onTap: () async {
                      final club = await vm.selectClub(r.placeId);
                      if (club != null && context.mounted) {
                        Navigator.pop(context, club);
                      }
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecentClubsSection extends StatelessWidget {
  const _RecentClubsSection({
    required this.clubs,
    required this.onTap,
  });

  final List<ClubPlace> clubs;
  final ValueChanged<ClubPlace> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
          child: Text(
            'Recent clubs:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...clubs.map(
          (club) => Padding(
            padding: const EdgeInsets.only(bottom: defaultPadding / 2),
            child: LocationCard(
              name: club.name,
              address: club.address,
              onTap: () => onTap(club),
              recent: true,
            ),
          ),
        ),
      ],
    );
  }
}

class LocationCard extends StatelessWidget {
  final String name;
  final String address;
  final VoidCallback onTap;
  final bool recent;

  const LocationCard({
    required this.name,
    required this.address,
    required this.onTap,
    this.recent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(defaultBorderRadious * 2),
      child: Container(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(defaultBorderRadious * 2),
        ),
        padding: const EdgeInsets.fromLTRB(
          defaultPadding,
          defaultPadding / 2,
          defaultPadding,
          defaultPadding / 2,
        ),
        child: Row(
          children: [
            if (recent) ...[
              const Icon(Icons.history, color: Colors.white60)
            ] else ...[
              const Icon(Icons.location_on_outlined, color: Colors.white60)
            ],
            const SizedBox(width: defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    address,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: defaultPadding),
            const Icon(Icons.chevron_right, color: whiteColor),
          ],
        ),
      ),
    );
  }
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
