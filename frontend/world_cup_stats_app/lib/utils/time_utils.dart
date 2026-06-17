import 'package:timezone/timezone.dart' as tz;

DateTime toUkTime(DateTime utc) {
  final london = tz.getLocation('Europe/London');
  return tz.TZDateTime.from(utc.toUtc(), london);
}
