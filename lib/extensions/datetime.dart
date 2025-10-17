import 'package:intl/intl.dart';

// final _formatter = DateFormat('y/MM/dd HH:mm:ss');
final _formatter = DateFormat('y/MM/dd HH:mm');

extension DateTimeExt on DateTime {
  String get formatted => _formatter.format(this);
}
