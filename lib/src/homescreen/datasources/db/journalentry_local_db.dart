import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'journalentry_local_db.g.dart';

class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get date => text()();
  TextColumn get mood => text()();
  TextColumn get textContent => text()();
  TextColumn get sleepHours => text().nullable()();
  TextColumn get exerciseMinutes => text().nullable()();
  TextColumn get meals => text().nullable()();
}

@DriftDatabase(tables: [JournalEntries])
class JournalDatabase extends _$JournalDatabase {
  JournalDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'journal_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}