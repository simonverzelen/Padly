import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:padly/core/components/category_button.dart';
import 'package:padly/core/constants.dart';
import 'package:padly/core/route/route_constants.dart';
import 'package:padly/features/users/domain/entities/padly_user.dart';

import 'package:padly/features/games/domain/entities/club.dart';
import 'package:padly/features/games/domain/entities/game.dart';
import 'package:padly/features/games/presentation/notifiers/create_game_viewmodel.dart';

class CreateMatchScreen extends ConsumerStatefulWidget {
  final Game? initialGame;

  const CreateMatchScreen({super.key, this.initialGame});

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(createGameNotifierProvider.notifier).init(widget.initialGame);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createGameNotifierProvider);
    final notifier = ref.read(createGameNotifierProvider.notifier);

    ref.listen<CreateGameState>(createGameNotifierProvider, (previous, next) {
      if (previous?.isSuccess != next.isSuccess && next.isSuccess) {
        if (next.createdGameId != null) {
          // NEW game — navigate to celebration screen
          final selectedDate = next.dateList[next.selectedDate!];
          final startTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            next.selectedTime!.hour,
            next.selectedTime!.minute,
          );
          final durationMinutes = next.playTime ?? 90;
          final endTime = startTime.add(Duration(minutes: durationMinutes));
          final game = Game(
            id: next.createdGameId,
            club: next.location?.name,
            location: next.location?.city,
            date: selectedDate,
            startTime: startTime,
            endTime: endTime,
            rankingMin: next.levelList[next.minLevelIndex],
            rankingMax: next.levelList[next.maxLevelIndex],
            maxPlayers: int.tryParse(
              next.playersAmountList[next.playersAmountIndex ?? 1],
            ),
            pricePerHour: next.price,
            currentPlayers: next.currentPlayers,
          );
          Navigator.pushReplacementNamed(
            context,
            gameCreatedScreenRoute,
            arguments: {'game': game},
          );
        } else {
          // EDIT — go back to home
          Navigator.pushNamedAndRemoveUntil(
            context,
            entryPointScreenRoute,
            (_) => false,
          );
        }
      } else if (previous?.error != next.error && next.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          notifier.isEditing ? 'Pas match aan' : 'Maak een match',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(label: 'Spelers:'),
            const CurrentPlayers(),
            const SizedBox(height: defaultPadding / 2),
            const SectionTitle(label: 'Locatie:'),
            const LocationCard(),
            const SizedBox(height: defaultPadding / 2),
            const SectionTitle(label: 'Selecteer een sport:'),
            const Sport(),
            const SizedBox(height: defaultPadding / 2),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(label: 'Aantal spelers:'),
                    PlayersAmount(),
                  ],
                ),
                SizedBox(width: defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(label: 'Geslacht:'),
                      Gender(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),
            const Row(
              children: [
                Expanded(
                  child: SectionTitle(
                    label: 'Niveau minimum:',
                  ),
                ),
                SizedBox(width: defaultPadding),
                Expanded(
                  child: SectionTitle(
                    label: 'Niveau maximum:',
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Expanded(
                  child: SelectedMinLevel(),
                ),
                SizedBox(width: defaultPadding),
                Expanded(child: SelectedMaxLevel()),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),
            const SectionTitle(label: 'Selecteer datum en tijd:'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateTimePicker(),
                  ],
                ),
                const SizedBox(width: defaultPadding),
                const Expanded(
                  child: PlayTimePicker(),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding / 2),
            const Row(
              children: [
                Expanded(child: SectionTitle(label: 'Naam terrein:')),
                SizedBox(width: defaultPadding),
                Expanded(child: SectionTitle(label: 'Prijs:')),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                      label: "Naam terrein",
                      value: state.nameCourt,
                      onChanged: notifier.setNameCourt),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                    child: TextInputField(
                        label: '€ 0,00',
                        value: state.price,
                        onChanged: notifier.setPrice)),
              ],
            ),
            const SizedBox(height: defaultPadding * 2),
          ],
        ),
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
              onPressed: state.canCreateGame && !state.isSaving
                  ? notifier.saveGame
                  : null,
              child: state.isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ))
                  : Text(notifier.isEditing ? 'Opslaan' : 'Maak Match'),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String label;

  const SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: defaultPadding, bottom: defaultPadding / 2),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class LocationCard extends ConsumerWidget {
  const LocationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createGameNotifierProvider);
    final notifier = ref.read(createGameNotifierProvider.notifier);
    return InkWell(
      onTap: () async {
        final result =
            await Navigator.pushNamed(context, searchClubScreenRoute);

        if (result is ClubPlace) {
          notifier.setLocation(result);
        }
      },
      borderRadius: BorderRadius.circular(defaultBorderRadious * 2),
      child: Container(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(defaultBorderRadious * 2),
        ),
        padding: const EdgeInsets.all(defaultPadding),
        child: Row(
          children: [
            if (state.location != null) ...[
              const Icon(LucideIcons.mapPin, color: Colors.white60)
            ] else ...[
              Icon(
                LucideIcons.search,
                size: 24,
                color: Theme.of(context).inputDecorationTheme.hintStyle!.color,
              ),
            ],
            const SizedBox(width: defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.location != null) ...[
                    Text(
                      state.location!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      state.location!.address,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Selecteer een club',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: whiteColor),
          ],
        ),
      ),
    );
  }
}

class ChipRowScroll extends StatefulWidget {
  final List<String> options;
  final int? selected;
  final ValueChanged<int>? onSelect;

  const ChipRowScroll({
    super.key,
    required this.options,
    this.selected,
    this.onSelect,
  });

  @override
  State<ChipRowScroll> createState() => _ChipRowScrollState();
}

class _ChipRowScrollState extends State<ChipRowScroll> {
  late final ScrollController _controller;
  late List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _keys = List.generate(widget.options.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant ChipRowScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.length != oldWidget.options.length) {
      _keys = List.generate(widget.options.length, (_) => GlobalKey());
    }
    if (widget.selected != null && widget.selected != oldWidget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(widget.selected!);
      });
    }
  }

  Future<void> _scrollToIndex(int index) async {
    if (!_controller.hasClients) return;
    final ctx = _keys[index].currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final size = box.size;

    // Position of chip inside scroll view
    final position =
        box.localToGlobal(Offset.zero, ancestor: context.findRenderObject()).dx;

    final viewportWidth = _controller.position.viewportDimension;

    final target =
        _controller.offset + position + (size.width / 2) - (viewportWidth / 2);

    await _controller.animateTo(
      target.clamp(
        _controller.position.minScrollExtent,
        _controller.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: scrollBackgroundColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious * 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          controller: _controller,
          primary: false,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: defaultPadding / 1.5,
          ),
          child: Row(
            children: List.generate(
              widget.options.length,
              (index) {
                return Padding(
                  key: _keys[index],
                  padding: EdgeInsets.only(
                    left:
                        index == 0 ? defaultPadding / 1.5 : defaultPadding / 2,
                    right:
                        index == widget.options.length - 1 ? defaultPadding : 0,
                  ),
                  child: CategoryButton(
                    text: widget.options[index],
                    isActive: index == widget.selected,
                    press: () async {
                      if (widget.onSelect == null || widget.selected == index) {
                        return;
                      }
                      widget.onSelect?.call(index);
                      await Future.delayed(Duration.zero);
                      _scrollToIndex(index);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ChipRow extends StatelessWidget {
  final List<String> options;
  final int? selected;
  final ValueChanged<int>? onSelect;

  ChipRow({required this.options, this.selected, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: scrollBackgroundColor,
          borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding / 1.5),
          child: Wrap(
            spacing: defaultPadding / 2,
            runSpacing: defaultPadding / 1.5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: List.generate(
              options.length,
              (index) => CategoryButton(
                text: options[index],
                isActive: selected == index,
                press: () {
                  if (onSelect == null || selected == index) return;
                  onSelect?.call(index);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Sport extends ConsumerWidget {
  const Sport({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createGameNotifierProvider);
    final notifier = ref.read(createGameNotifierProvider.notifier);

    return ChipRowScroll(
      options: state.sportList,
      selected: state.selectedSportIndex,
      onSelect: (index) {
        notifier.selectSport(index);
      },
    );
  }
}

class SelectedMinLevel extends ConsumerWidget {
  const SelectedMinLevel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createGameNotifierProvider);
    final notifier = ref.read(createGameNotifierProvider.notifier);

    return ChipRowScroll(
      options: state.levelList,
      selected: state.minLevelIndex,
      onSelect: (index) {
        notifier.selectMinLevel(index);
      },
    );
  }
}

class SelectedMaxLevel extends ConsumerWidget {
  const SelectedMaxLevel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createGameNotifierProvider);
    final notifier = ref.read(createGameNotifierProvider.notifier);

    return ChipRowScroll(
      options: state.levelList,
      selected: state.maxLevelIndex,
      onSelect: (index) {
        notifier.selectMaxLevel(index);
      },
    );
  }
}

class PlayersAmount extends ConsumerWidget {
  const PlayersAmount({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createGameNotifierProvider);
    final notifier = ref.read(createGameNotifierProvider.notifier);

    return ChipRowScroll(
      options: state.playersAmountList,
      selected: state.playersAmountIndex,
      onSelect: (index) {
        notifier.selectPlayersAmount(index);
      },
    );
  }
}

class Gender extends ConsumerWidget {
  const Gender({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createGameNotifierProvider);
    final notifier = ref.read(createGameNotifierProvider.notifier);

    return ChipRowScroll(
      options: state.genderList,
      selected: state.genderIndex,
      onSelect: (index) {
        notifier.selectGender(index);
      },
    );
  }
}

class DateButton extends StatelessWidget {
  const DateButton({
    super.key,
    required this.date,
    required this.isActive,
    required this.press,
  });

  final DateTime date;
  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius:
          const BorderRadius.all(Radius.circular(defaultBorderRadious)),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding, vertical: defaultPadding / 2),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : pillBackgroundColor,
          border:
              Border.all(color: isActive ? Colors.transparent : primaryColor),
          borderRadius:
              const BorderRadius.all(Radius.circular(defaultBorderRadious / 3)),
        ),
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 0,
          children: [
            Text(
              DateFormat.E().format(date),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive ? backgroundColor : whiteColor,
              ),
            ),
            Text(
              DateFormat.d().format(date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isActive ? backgroundColor : whiteColor,
              ),
            ),
            Text(
              DateFormat.MMM().format(date),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive ? backgroundColor : whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DatePicker extends StatelessWidget {
  const DatePicker({
    super.key,
    required this.isActive,
    required this.press,
  });

  final bool isActive;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius:
          const BorderRadius.all(Radius.circular(defaultBorderRadious)),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding, vertical: defaultPadding / 2),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : pillBackgroundColor,
          border:
              Border.all(color: isActive ? Colors.transparent : primaryColor),
          borderRadius:
              const BorderRadius.all(Radius.circular(defaultBorderRadious / 3)),
        ),
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 0,
          children: [
            Text(
              'Kies',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? backgroundColor : whiteColor,
              ),
            ),
            Text(
              'Datum',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? backgroundColor : whiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateTimePicker extends ConsumerWidget {
  DateTimePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createGameNotifierProvider);
    final notifier = ref.read(createGameNotifierProvider.notifier);
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: scrollBackgroundColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious * 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          primary: false,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: defaultPadding / 1.5,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: defaultPadding / 1.5),
            child: Row(
              children: [
                CategoryButton(
                  text: state.selectedDate != null
                      ? '${DateFormat.E().format(state.dateList[state.selectedDate!])} ${DateFormat.d().format(state.dateList[state.selectedDate!])} ${DateFormat.MMM().format(state.dateList[state.selectedDate!])}'
                      : 'Datum',
                  isActive: false,
                  press: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: state.dateList.first,
                      initialDate:
                          state.dateList[state.selectedDate ?? 0],
                      lastDate:
                          DateTime.now().add(const Duration(days: 30)),
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                    );

                    if (date == null) return;

                    notifier.selectDate(date);
                  },
                ),
                const SizedBox(width: defaultPadding / 2),
                CategoryButton(
                  text: state.selectedDate != null
                      ? '${state.selectedTime != null ? DateFormat('HH:mm').format(state.selectedTime!) : 'Tijd'}'
                      : 'Tijd',
                  isActive: false,
                  press: () async {
                    if (state.selectedDate == null) return;

                    final TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                      initialEntryMode: TimePickerEntryMode.dialOnly,
                    );

                    if (selectedTime == null) return;

                    notifier.selectTime(DateTime(
                      state.dateList[state.selectedDate!].year,
                      state.dateList[state.selectedDate!].month,
                      state.dateList[state.selectedDate!].day,
                      selectedTime.hour,
                      selectedTime.minute,
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TextInputField extends StatelessWidget {
  final String label;
  final dynamic value;
  final Function(dynamic) onChanged;

  const TextInputField({
    required this.label,
    required this.value,
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

class CurrentPlayers extends StatelessWidget {
  const CurrentPlayers();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
      ),
      elevation: 0,
      child: const Padding(
        padding: EdgeInsets.fromLTRB(
          defaultPadding,
          defaultPadding,
          defaultPadding,
          0,
        ),
        child: _CurrentPlayersList(),
      ),
    );
  }
}

class _CurrentPlayersList extends ConsumerWidget {
  const _CurrentPlayersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createGameNotifierProvider);
    final notifier = ref.read(createGameNotifierProvider.notifier);
    final players = state.currentPlayers;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 0; i < 4; i++) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(defaultPadding / 8),
                decoration: BoxDecoration(
                  color: i < players.length ? whiteColor : null,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      addPlayersScreenRoute,
                      arguments: {
                        'maxPlayers': state.playersAmountIndex,
                        'initialPlayers': players,
                        'lockedPlayerId': notifier.lockedPlayerId,
                      },
                    );
                    if (result is List<PadlyUser>) {
                      notifier.setPlayers(result);
                    }
                  },
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: pillBackgroundColor,
                    backgroundImage: i < players.length &&
                            players[i].imageUrl != null
                        ? NetworkImage(players[i].imageUrl!)
                        : null,
                    child: i >= players.length
                        ? Icon(
                            LucideIcons.plus,
                            size: defaultPadding * 1.5,
                            color: whiteColor,
                          )
                        : null,
                  ),
                ),
              ),
              if (i < players.length) ...[
                const SizedBox(height: defaultPadding / 4),
                Text(players[i].firstName ?? '',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: whiteColor,
                        )),
                Transform(
                  transform: Matrix4.identity()
                    ..scale(0.8)
                    ..translate(8.0, 0.0),
                  child: Chip(
                    labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                    backgroundColor: whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.transparent),
                    ),
                    label: Text(
                      players[i].rank ?? '',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: backgroundColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: defaultPadding / 4),
                Text('Kies Speler',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: whiteColor,
                        )),
              ]
            ],
          ),
        ],
      ],
    );
  }
}

class PlayTimePicker extends ConsumerWidget {
  const PlayTimePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createGameNotifierProvider);
    final notifier = ref.read(createGameNotifierProvider.notifier);

    return ChipRowScroll(
      options: state.playTimeList.map((e) => '$e min').toList(),
      selected: state.playTimeList.indexOf(state.playTime ?? 90),
      onSelect: (index) {
        notifier.selectTotalPlayTime(state.playTimeList[index]);
      },
    );
  }
}
