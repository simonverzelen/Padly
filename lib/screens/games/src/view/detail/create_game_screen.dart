import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:padly/components/category_button.dart';
import 'package:padly/constants.dart';
import 'package:padly/route/route_constants.dart';
import 'package:padly/screens/user_info/src/domain/padly_user.dart';
import 'package:provider/provider.dart';

import '../../domain/club.dart';
import '../../domain/games_services.dart';
import 'create_game_viewmodel.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  late final CreateGameViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = CreateGameViewModel(gameService: GamesServices());
    _vm.addListener(_onVmChanged);
  }

  void _onVmChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_vm.isSuccess) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          entryPointScreenRoute,
          (_) => false,
        );
      } else if (_vm.error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_vm.error!)));
      }
    });
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      builder: (context, child) {
        final vm = context.watch<CreateGameViewModel>();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Maak een match',
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
                          value: vm.nameCourt,
                          onChanged: vm.setNameCourt),
                    ),
                    const SizedBox(width: defaultPadding),
                    Expanded(
                        child: TextInputField(
                            label: '€ 0,00',
                            value: vm.price,
                            onChanged: vm.setPrice)),
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
                  onPressed:
                      vm.canCreateGame && !vm.isSaving ? vm.createGame : null,
                  child: vm.isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ))
                      : const Text('Maak Match'),
                ),
              ),
            ),
          ),
        );
      },
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

class LocationCard extends StatelessWidget {
  const LocationCard();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateGameViewModel>();
    return InkWell(
      onTap: () async {
        final result =
            await Navigator.pushNamed(context, searchClubScreenRoute);

        if (result is ClubPlace) {
          vm.setLocation(result);
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
            if (vm.location != null) ...[
              const Icon(Icons.location_on_outlined, color: Colors.white60)
            ] else ...[
              SvgPicture.asset(
                "assets/icons/Search.svg",
                height: 24,
                color: Theme.of(context).inputDecorationTheme.hintStyle!.color,
              ),
            ],
            const SizedBox(width: defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vm.location != null) ...[
                    Text(
                      vm.location!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      vm.location!.address,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Selecteer een club',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: whiteColor),
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
  late final List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _keys = List.generate(widget.options.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant ChipRowScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
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
          primary: false, // 👈 prevents whole screen from moving
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
                      if (widget.onSelect == null || widget.selected == index)
                        return;
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

class Sport extends StatelessWidget {
  const Sport({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateGameViewModel>();

    return ChipRowScroll(
      options: vm.sportList,
      selected: vm.selectedSport,
      onSelect: (index) {
        vm.selectSport(index);
      },
    );
  }
}

class SelectedMinLevel extends StatelessWidget {
  const SelectedMinLevel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateGameViewModel>();

    return ChipRowScroll(
      options: vm.levelList,
      selected: vm.minLevel,
      onSelect: (index) {
        vm.selectMinLevel(index);
      },
    );
  }
}

class SelectedMaxLevel extends StatelessWidget {
  const SelectedMaxLevel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateGameViewModel>();

    return ChipRowScroll(
      options: vm.levelList,
      selected: vm.maxLevel,
      onSelect: (index) {
        vm.selectMaxLevel(index);
      },
    );
  }
}

class PlayersAmount extends StatelessWidget {
  const PlayersAmount({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateGameViewModel>();

    return ChipRowScroll(
      options: vm.playersAmountList,
      selected: vm.playersAmount,
      onSelect: (index) {
        vm.selectPlayersAmount(index);
      },
    );
  }
}

class Gender extends StatelessWidget {
  const Gender({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateGameViewModel>();

    return ChipRowScroll(
      options: vm.genderList,
      selected: vm.gender,
      onSelect: (index) {
        vm.selectGender(index);
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

class DateTimePicker extends StatelessWidget {
  DateTimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateGameViewModel>();
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: scrollBackgroundColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious * 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          primary: false, // 👈 prevents whole screen from moving
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
                  text: vm.selectedDate != null
                      ? '${DateFormat.E().format(vm.dateList[vm.selectedDate!])} ${DateFormat.d().format(vm.dateList[vm.selectedDate!])} ${DateFormat.MMM().format(vm.dateList[vm.selectedDate!])}'
                      : 'Datum',
                  isActive: false,
                  press: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: vm.dateList.first,
                      initialDate: vm.dateList[vm.selectedDate ?? 0],
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                    );

                    if (date == null) return;

                    vm.selectDate(date);
                  },
                ),
                const SizedBox(width: defaultPadding / 2),
                CategoryButton(
                  text: vm.selectedDate != null
                      ? '${vm.selectedTime != null ? DateFormat('HH:mm').format(vm.selectedTime!) : 'Tijd'}'
                      : 'Tijd',
                  isActive: false,
                  press: () async {
                    if (vm.selectedDate == null) return;

                    final TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                      initialEntryMode: TimePickerEntryMode.dialOnly,
                    );

                    if (selectedTime == null) return;

                    vm.selectTime(DateTime(
                      vm.dateList[vm.selectedDate!].year,
                      vm.dateList[vm.selectedDate!].month,
                      vm.dateList[vm.selectedDate!].day,
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

class _CurrentPlayersList extends StatelessWidget {
  const _CurrentPlayersList();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateGameViewModel>();
    final players = vm.currentPlayers;

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
                        'maxPlayers': vm.playersAmount,
                        'initialPlayers': players,
                        'lockedPlayerId': vm.lockedPlayerId,
                      },
                    );
                    if (result is List<PadlyUser>) {
                      vm.setPlayers(result);
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
                        ? SvgPicture.asset(
                            "assets/icons/Plus1.svg",
                            height: defaultPadding * 1.5,
                            colorFilter: const ColorFilter.mode(
                                whiteColor, BlendMode.srcIn),
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

class PlayTimePicker extends StatelessWidget {
  const PlayTimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateGameViewModel>();

    return ChipRowScroll(
      options: vm.playTimeList.map((e) => '$e min').toList(),
      selected: vm.playTimeList.indexOf(vm.playTime ?? 90),
      onSelect: (index) {
        vm.selectTotalPlayTime(vm.playTimeList[index]);
      },
    );
  }
}
