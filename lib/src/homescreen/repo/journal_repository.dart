import 'package:drift/drift.dart';
import 'package:flutter_assignment/src/homescreen/datasources/db/journalentry_local_db.dart';
import 'package:flutter_assignment/src/homescreen/models/journal_entry.dart' as domain;

class JournalRepo {
  JournalRepo(this.journalDatabase);

  final JournalDatabase journalDatabase;


  Future<List<domain.JournalEntry>> getEntries() async {
    final localEntries = await journalDatabase.managers.journalEntries.get();

    return localEntries.map(
          (entry) => domain.JournalEntry(
        id: entry.id.toString(),
        date: entry.date,
        mood: entry.mood,
        text: entry.textContent,
        sleepHours: int.tryParse(entry.sleepHours ?? ''),
        exerciseMinutes: int.tryParse(entry.exerciseMinutes ?? "No exercise introduced"),
        meals: entry.meals ?? "No meals introduced",
      ),
    ).toList();
  }

  Future<domain.JournalEntry> getEntryById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) throw Exception("Invalid ID");

    final query = journalDatabase.select(journalDatabase.journalEntries)
      ..where((tbl) => tbl.id.equals(intId));

    final localItem = await query.getSingle();

    return domain.JournalEntry(
      id: localItem.id.toString(),
      date: localItem.date,
      mood: localItem.mood,
      text: localItem.textContent,
      sleepHours: int.tryParse(localItem.sleepHours ?? "No sleep introduced"),
      exerciseMinutes: int.tryParse(localItem.exerciseMinutes ?? "No exercise introduced"),
      meals: localItem.meals ?? "No meals introduced",
    );
  }

  Future<domain.JournalEntry> createEntry(String mood, String textContent, String? sleepHours, String? exerciseMinutes, String? meals) async {
    final newID = await journalDatabase.managers.journalEntries.create(
          (row) =>
          row(
            date: DateTime.now().toString().split(' ')[0],
            mood: mood,
            textContent: textContent,
            sleepHours: Value(sleepHours),
            exerciseMinutes: Value(exerciseMinutes),
            meals: Value(meals),
          ),
    );

    final newEntry = await journalDatabase.managers.journalEntries.filter((f) => f.id(newID)).getSingle();

    return domain.JournalEntry(
      id: newEntry.id.toString(),
      date: newEntry.date,
      mood: newEntry.mood,
      text: newEntry.textContent,
      sleepHours: int.tryParse(newEntry.sleepHours ?? "No sleep introduced"),
      exerciseMinutes: int.tryParse(newEntry.exerciseMinutes ?? "No exercise introduced"),
      meals: newEntry.meals ?? "No meals introduced",
    );
  }

  Future<domain.JournalEntry> updateEntry(String id, String mood, String textContent, String? sleepHours, String? exerciseMinutes, String? meals) async {
    final intId = int.tryParse(id);
    if (intId == null) throw Exception("Invalid ID");

    await journalDatabase.managers.journalEntries
        .filter((f) => f.id(intId))
        .update(
          (row) => row(
        mood: Value(mood),
        textContent: Value(textContent),
        sleepHours: Value(sleepHours),
        exerciseMinutes: Value(exerciseMinutes),
        meals: Value(meals),
      ),
    );

    final updatedEntry = await journalDatabase.managers.journalEntries.filter((f) => f.id(intId)).getSingle();

    return domain.JournalEntry(
      id: updatedEntry.id.toString(),
      date: updatedEntry.date,
      mood: updatedEntry.mood,
      text: updatedEntry.textContent,
      sleepHours: int.tryParse(updatedEntry.sleepHours ?? "No sleep introduced"),
      exerciseMinutes: int.tryParse(updatedEntry.exerciseMinutes ?? "No exercise introduced"),
      meals: updatedEntry.meals ?? "No meals introduced",
    );
  }

  Future<void> deleteEntry(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) throw Exception("Invalid ID");

    await journalDatabase.managers.journalEntries
        .filter((f) => f.id(intId))
        .delete();
  }
}