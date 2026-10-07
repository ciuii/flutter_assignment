import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment/src/homescreen/repo/journal_repository.dart';
import 'package:flutter_assignment/src/homescreen/models/journal_entry.dart' as domain;

import '../../homescreen/datasources/server/server_repository.dart';
import '../../homescreen/models/journal_entry.dart';

class DetailsViewModel extends ChangeNotifier {
  DetailsViewModel({required this.journalRepo});

  final ServerJournalRepo journalRepo;
  DetailsScreenState? detailsScreenState;
  String? errorMsg;


  void onLoadEntry(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final entry = await journalRepo.getEntryById(id);
      detailsScreenState = DetailsScreenState(
        id: entry.id.toString(),
        date: entry.date,
        mood: entry.mood,
        text: entry.text.toString(),
        sleepHours: entry.sleepHours.toString(),
        exerciseMinutes: entry.exerciseMinutes.toString(),
        meals: entry.meals.toString(),
        entry: entry
      );
    } catch (e) {
      detailsScreenState = null;
    }
    notifyListeners();
  }

  void updateEntry(String id, String mood, String text, String sleep, String exercise, String meals, String imagePath) async {
    try {
      await journalRepo.updateEntry(id, mood, text, sleep, exercise, meals, imagePath);
      onLoadEntry(id);
    } catch (e) {
      errorMsg = "Failed to save changes.";
      notifyListeners();
    }
  }

  void _updateState(JournalEntry entry) {
    detailsScreenState = DetailsScreenState(
      id: entry.id,
      date: entry.date,
      mood: entry.mood,
      text: entry.text,
      sleepHours: entry.sleepHours?.toString() ?? '',
      exerciseMinutes: entry.exerciseMinutes?.toString() ?? '',
      meals: entry.meals,
      imagePath: entry.imagePath,
      entry: entry,
    );
  }

  void onDisposed() {
    detailsScreenState = null;
    notifyListeners();
  }
}

class DetailsScreenState extends Equatable {
  const DetailsScreenState({
    required this.id,
    required this.date,
    required this.mood,
    required this.text,
    this.sleepHours,
    this.exerciseMinutes,
    this.meals,
    this.imagePath,
    required this.entry,
  });

  final String id;
  final String date;
  final String mood;
  final String text;
  final String? sleepHours;
  final String? exerciseMinutes;
  final String? meals;
  final String? imagePath;
  final entry;


  @override
  List<Object?> get props => [id, date, mood, text, sleepHours, exerciseMinutes, meals, entry];
}