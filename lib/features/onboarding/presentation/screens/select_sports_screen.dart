import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:padly/core/constants.dart';
import 'package:padly/core/route/route_constants.dart';
import 'package:padly/features/games/data/repositories/sports_repository.dart';

class SelectSportsScreen extends StatefulWidget {
  const SelectSportsScreen({super.key});

  @override
  State<SelectSportsScreen> createState() => _SelectSportsScreenState();
}

class _SelectSportsScreenState extends State<SelectSportsScreen> {
  final Set<String> _sports = {};
  List<String> _sportNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSports();
  }

  Future<void> _loadSports() async {
    final names = await SportsRepository.instance.getSports();
    setState(() {
      _sportNames = names;
      _isLoading = false;
    });
  }

  void _toggleSport(String sport) {
    setState(() {
      if (_sports.contains(sport)) {
        _sports.remove(sport);
      } else {
        _sports.add(sport);
      }
    });
  }

  void _onContinue() {
    Navigator.pushNamed(
      context,
      selectLevelsScreenRoute,
      arguments: _sports.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding * 2),
              Text(
                "Welke sporten beoefen jij?",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: defaultPadding / 2),
              const Text(
                'Selecteer alle sporten die je speelt.',
              ),
              const SizedBox(height: defaultPadding * 2),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _sportNames.length,
                        itemBuilder: (context, index) {
                          final sport = _sportNames[index];
                          final isSelected = _sports.contains(sport);

                          return GestureDetector(
                            onTap: () => _toggleSport(sport),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: defaultPadding / 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: defaultPadding,
                                  vertical: defaultPadding),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryMaterialColor.shade800
                                    : cardBackgroundColor,
                                borderRadius:
                                    BorderRadius.circular(defaultBorderRadious),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : cardBackgroundColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      sport,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      height: 24,
                                      width: 24,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(LucideIcons.check, size: 16, color: backgroundColor),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              ElevatedButton(
                onPressed: _sports.isEmpty ? null : _onContinue,
                child: const Text("Doorgaan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
