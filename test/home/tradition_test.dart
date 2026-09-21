import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/clock/data/sun_alarm.dart';
import 'package:advance_calendar/features/home/application/tradition_provider.dart';
import 'package:advance_calendar/features/home/data/tradition.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../profile/profile_support.dart';

void main() {
  final rise = DateTime(2026, 9, 22, 6, 5);
  final set = DateTime(2026, 9, 22, 18, 12);
  List<TodayDetail> details(Tradition t) =>
      todayDetails(t, sunrise: rise, sunset: set);
  List<String> labels(Tradition t) => [for (final d in details(t)) d.label];

  group('the details for each tradition', () {
    test('Hindu: tithi, nakshatra, Rahu Kaal, Abhijit muhurat', () {
      expect(labels(Tradition.hindu),
          ['Tithi', 'Nakshatra', 'Rahu Kaal', 'Abhijit muhurat']);
    });

    test('Sikh: Hukamnama (Ang), Nitnem due, sunrise, next Gurpurab', () {
      expect(labels(Tradition.sikh),
          ['Hukamnama', 'Nitnem due', 'Sunrise', 'Next Gurpurab']);
      expect(details(Tradition.sikh).first.value, matches(RegExp(r'^Ang \d+$')));
    });

    test('By place: sunrise, sunset, local festival, auspicious window', () {
      expect(labels(Tradition.place),
          ['Sunrise', 'Sunset', 'Local festival', 'Auspicious window']);
    });

    test('the switch has exactly Hindu / Sikh / By place', () {
      expect([for (final t in Tradition.values) t.label], ['Hindu', 'Sikh', 'By place']);
    });

    test('every line has a value and an icon', () {
      for (final t in Tradition.values) {
        for (final d in details(t)) {
          expect(d.value, isNotEmpty, reason: '${t.name} ${d.label}');
          expect(d.key, isNotEmpty);
        }
      }
    });

    test('line keys are unique within a tradition', () {
      for (final t in Tradition.values) {
        final keys = [for (final d in details(t)) d.key];
        expect(keys.toSet().length, keys.length, reason: t.name);
      }
    });
  });

  group('what is real and what is an example', () {
    test('sunrise and sunset are real; everything else is an EXAMPLE', () {
      for (final t in Tradition.values) {
        for (final d in details(t)) {
          final isSun = d.key == 'sunrise' || d.key == 'sunset';
          expect(d.example, !isSun, reason: '${t.name} ${d.label}');
        }
      }
    });

    test('real sunrise and sunset show the time given', () {
      final time = DateFormat.jm();
      final s = details(Tradition.place);
      expect(s[0].value, time.format(rise));
      expect(s[1].value, time.format(set));
    });

    test('no sunrise (polar) shows a dash, not a made-up time', () {
      final s = todayDetails(Tradition.place, sunrise: null, sunset: null);
      expect((s[0].value, s[1].value), ('—', '—'));
    });

    test('example values are the documented placeholders', () {
      final hindu = details(Tradition.hindu);
      expect(hindu[0].value, ExampleValues.tithi);
      expect(hindu[2].value, ExampleValues.rahuKaal);
      expect(details(Tradition.sikh)[1].value, ExampleValues.nitnem);
      expect(details(Tradition.place)[2].value, ExampleValues.localFestival);
    });
  });

  group('the greeting', () {
    test('by the hour', () {
      expect(greetingFor(5), 'Good morning');
      expect(greetingFor(11), 'Good morning');
      expect(greetingFor(12), 'Good afternoon');
      expect(greetingFor(16), 'Good afternoon');
      expect(greetingFor(17), 'Good evening');
      expect(greetingFor(20), 'Good evening');
      expect(greetingFor(21), 'Good night');
      expect(greetingFor(0), 'Good night');
      expect(greetingFor(4), 'Good night');
    });

    test('every hour of the day has one', () {
      for (var h = 0; h < 24; h++) {
        expect(greetingFor(h), startsWith('Good '));
      }
    });
  });

  group('the chosen tradition', () {
    test('none chosen to begin with; Home shows Hindu', () {
      final c = profileRig().container;
      expect(c.read(traditionProvider), isNull);
      expect(c.read(effectiveTraditionProvider), Tradition.hindu);
    });

    test('choosing is saved and remembered', () {
      final c = profileRig().container;
      c.read(traditionProvider.notifier).set(Tradition.sikh);
      expect(c.read(effectiveTraditionProvider), Tradition.sikh);
      expect(AppStorage.settings.get('home.tradition'), 'sikh');
      final again = profileRig(saved: {'home.tradition': 'sikh'}).container;
      expect(again.read(traditionProvider), Tradition.sikh);
    });

    test('an unknown saved value means none chosen', () {
      final c = profileRig(saved: {'home.tradition': 'martian'}).container;
      expect(c.read(traditionProvider), isNull);
      expect(Tradition.byName(null), isNull);
    });

    test('the lines follow the choice', () {
      final c = profileRig().container;
      List<String> now() => [for (final d in c.read(todayDetailsProvider)) d.label];
      expect(now().first, 'Tithi');
      c.read(traditionProvider.notifier).set(Tradition.sikh);
      expect(now().first, 'Hukamnama');
      c.read(traditionProvider.notifier).set(Tradition.place);
      expect(now().first, 'Sunrise');
    });

    test('the real sunrise and sunset come from the phone\'s place (Amritsar '
        'when it does not know)', () {
      final c = profileRig().container;
      c.read(traditionProvider.notifier).set(Tradition.place);
      final time = DateFormat.jm();
      final day = DateTime(2026, 9, 21);
      final want = sunEventOn(SunEventKind.sunrise, day, 31.6340, 74.8723)!;
      expect(c.read(todayDetailsProvider).first.value, time.format(want));
    });
  });
}
