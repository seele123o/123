import 'package:drift/drift.dart';

class DurationTypeConverter extends TypeConverter<Duration, int> {
  const DurationTypeConverter();

  @override
  Duration? mapToDart(int? fromDb) {
    if (fromDb == null) return null;
    return Duration(seconds: fromDb);
  }

  @override
  int? mapToSql(Duration? value) {
    if (value == null) return null;
    return value.inSeconds;
  }
}
