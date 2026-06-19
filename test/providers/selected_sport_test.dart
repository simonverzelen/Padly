import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padly/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('SelectedSportNotifier updates state on setSport', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(selectedSportProvider.notifier);

    await notifier.setSport('Tennis');
    expect(container.read(selectedSportProvider), equals('Tennis'));

    await notifier.setSport('Padel');
    expect(container.read(selectedSportProvider), equals('Padel'));
  });
}
