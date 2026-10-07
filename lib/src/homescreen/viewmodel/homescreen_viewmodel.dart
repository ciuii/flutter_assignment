import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../models/journal_entry.dart';
import '../repo/journal_repository.dart';
import '../datasources/server/server_repository.dart';

class HomescreenViewModel extends ChangeNotifier{
  HomescreenViewModel({required this.journalRepo}){
    subscription = journalRepo.entriesStream.listen((entries) {
      homescreenState = HomescreenState(entries: entries);
      notifyListeners();
    });
  }
  final ServerJournalRepo journalRepo;
  StreamSubscription? subscription;
  HomescreenState ?homescreenState;
  String? errorMsg;

  @override
  void dispose(){

    subscription?.cancel();
    super.dispose();
  }
  
  void onLoadEntries() async{
    try {
      errorMsg = null;
      final entries = await journalRepo.getEntries();
      homescreenState = HomescreenState(entries: entries);
    } catch (e) {
      homescreenState = const HomescreenState(entries: []);
      errorMsg = "Could not connect to server.";
    }
    notifyListeners();
  }

  void addEntry(String mood, String text, String sleep, String exercise, String? meals, String? imagePath) async {
    try{
      errorMsg = null;
      await journalRepo.createEntry(mood, text, sleep, exercise, meals, imagePath);
    }
    catch(e){
      errorMsg = "Could not add entry. Please check your connection.";
      notifyListeners();
    }


  }
  void deleteEntry(String id) async{
    try {
      errorMsg = null;
      await journalRepo.deleteEntry(id);
    } catch (e) {
      errorMsg = "Could not delete entry. Server might be down.";
      notifyListeners();
    }
  }


}

class HomescreenState extends Equatable{
  const HomescreenState({ required this.entries});
  final List<JournalEntry> entries;

  @override
  List<Object?> get props => [entries];

}