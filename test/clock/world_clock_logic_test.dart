import 'package:advance_calendar/features/clock/data/world_cities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WorldCity city(String name) => worldCities.firstWhere((c) => c.name == name);

  // A viewer on UTC (offset 0), at 21 Sep 2026 12:00 UTC.
  final noon = DateTime.utc(2026, 9, 21, 12);

  test('the list has Amritsar, Haridwar and London first', () {
    expect(
      [for (final c in worldCities.take(3)) c.name],
      ['Amritsar', 'Haridwar', 'London'],
    );
    expect(worldCities.length, greaterThanOrEqualTo(3));
  });

  test('Amritsar and Haridwar are on India time (UTC+5:30)', () {
    for (final n in ['Amritsar', 'Haridwar']) {
      final t = cityTimeAt(city(n), noon).time;
      expect((t.hour, t.minute), (17, 30), reason: n);
    }
  });

  test('London is on summer time in September and winter time in December', () {
    final sep = cityTimeAt(city('London'), noon).time;
    expect((sep.hour, sep.minute), (13, 0));
    final dec = cityTimeAt(city('London'), DateTime.utc(2026, 12, 21, 12)).time;
    expect((dec.hour, dec.minute), (12, 0));
  });

  test('other zones, daylight saving included', () {
    expect(cityTimeAt(city('New York'), noon).time.hour, 8); // EDT
    expect(
      cityTimeAt(city('New York'), DateTime.utc(2026, 12, 21, 12)).time.hour,
      7,
    ); // EST
    expect(cityTimeAt(city('Dubai'), noon).time.hour, 16);
    expect(cityTimeAt(city('Sydney'), noon).time.hour, 22); // AEST
    expect(
      cityTimeAt(city('Sydney'), DateTime.utc(2026, 12, 21, 12)).time.hour,
      23,
    ); // AEDT
  });

  test('the clock moves with the instant', () {
    final a = cityTimeAt(city('Amritsar'), noon).time;
    final b = cityTimeAt(
      city('Amritsar'),
      noon.add(const Duration(minutes: 47)),
    ).time;
    expect(b.difference(a), const Duration(minutes: 47));
  });

  test('today / tomorrow / yesterday against the viewer\'s date', () {
    final late = DateTime.utc(2026, 9, 21, 20, 0);
    expect(cityTimeAt(city('London'), late).dayLabel, 'Today'); // 21:00
    expect(
      cityTimeAt(city('Amritsar'), late).dayLabel,
      'Tomorrow',
    ); // 01:30 on the 22nd
    expect(
      cityTimeAt(city('Sydney'), late).dayLabel,
      'Tomorrow',
    ); // 06:00 on the 22nd
    final early = DateTime.utc(2026, 9, 21, 2, 0);
    expect(
      cityTimeAt(city('New York'), early).dayLabel,
      'Yesterday',
    ); // 22:00 on the 20th
    expect(cityTimeAt(city('London'), early).dayLabel, 'Today');
  });

  test('how far ahead or behind the viewer', () {
    expect(
      cityTimeAt(city('Amritsar'), noon).relativeLabel,
      '5 h 30 m ahead of you',
    );
    expect(cityTimeAt(city('London'), noon).relativeLabel, '1 h ahead of you');
    expect(cityTimeAt(city('New York'), noon).relativeLabel, '4 h behind you');
    expect(relativeToViewer(Duration.zero), 'Same time as you');
    expect(relativeToViewer(const Duration(minutes: -45)), '45 m behind you');
  });

  test('day and night follow the city\'s own hour', () {
    expect(cityTimeAt(city('Amritsar'), noon).isDaytime, isTrue); // 17:30
    expect(cityTimeAt(city('Sydney'), noon).isDaytime, isFalse); // 22:00
    expect(
      cityTimeAt(city('Dubai'), DateTime.utc(2026, 9, 21, 2)).isDaytime,
      isTrue,
    ); // 06:00
    expect(
      cityTimeAt(city('Dubai'), DateTime.utc(2026, 9, 21, 14)).isDaytime,
      isFalse,
    ); // 18:00
  });
}
