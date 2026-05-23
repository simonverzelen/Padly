import 'package:flutter/material.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/route_constants.dart';
import 'package:padly/screens/games/src/data/sports_repository.dart';
import 'package:padly/screens/user_info/src/domain/user_service.dart';

class SelectLevelsScreen extends StatefulWidget {
  final List<String> selectedSports;

  const SelectLevelsScreen({super.key, required this.selectedSports});

  @override
  State<SelectLevelsScreen> createState() => _SelectLevelsScreenState();
}

class _SelectLevelsScreenState extends State<SelectLevelsScreen> {
  final Map<String, String> _selectedLevels = {};
  final Map<String, List<String>> _sportLevels = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    for (final sport in widget.selectedSports) {
      final levels = await SportsRepository.instance.getLevelsForSport(sport);
      if (mounted) {
        setState(() {
          _sportLevels[sport] = levels;
        });
      }
    }
  }

  Future<void> _onContinue() async {
    setState(() => _isSaving = true);
    await UserService().saveSportsAndLevels(
      selectedSports: widget.selectedSports,
      sportLevels: _selectedLevels,
    );
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        entryPointScreenRoute,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding * 2),
              Text(
                "Wat is jouw niveau?",
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: defaultPadding / 2),
              const Text(
                'Geef je niveau op per sport.',
              ),
              const SizedBox(height: defaultPadding * 2),
              Expanded(
                child: ListView(
                  children: [
                    for (final sport in widget.selectedSports) ...[
                      Text(
                        sport,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: (_sportLevels[sport] ?? []).map((level) {
                            final isSelected =
                                _selectedLevels[sport] == level;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: defaultPadding / 2),
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _selectedLevels[sport] = level),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: defaultPadding,
                                    vertical: defaultPadding / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor
                                        : cardBackgroundColor,
                                    borderRadius: BorderRadius.circular(
                                        defaultBorderRadious),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : cardBackgroundColor,
                                    ),
                                  ),
                                  child: Text(
                                    level,
                                    style: TextStyle(
                                      color: isSelected
                                          ? backgroundColor
                                          : whiteColor,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                    ],
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _isSaving ? null : _onContinue,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Doorgaan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
