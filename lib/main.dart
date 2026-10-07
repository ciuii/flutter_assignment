import 'package:flutter/material.dart';
import 'package:flutter_assignment/src/details/screens/details.dart';
import 'package:flutter_assignment/src/details/viewmodel/details_viewmodel.dart';
import 'package:flutter_assignment/src/homescreen/datasources/db/journalentry_local_db.dart';
import 'package:flutter_assignment/src/homescreen/datasources/server/server_repository.dart';
import 'package:flutter_assignment/src/homescreen/repo/journal_repository.dart';
import 'package:flutter_assignment/src/homescreen/screens/homescreen.dart';
import 'package:flutter_assignment/src/homescreen/viewmodel/homescreen_viewmodel.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final journalRepository = ServerJournalRepo();



  final homescreenViewModel = HomescreenViewModel(
    journalRepo: journalRepository,
  );


    final detailsViewModel = DetailsViewModel(
    journalRepo: journalRepository,
  );

  runApp(
    MyApp(
      homescreenViewModel: homescreenViewModel,
      detailsViewModel: detailsViewModel,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.homescreenViewModel,
    required this.detailsViewModel,
  });
  final HomescreenViewModel homescreenViewModel;
  final DetailsViewModel detailsViewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Journal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => Homescreen(homescreenViewModel: homescreenViewModel),
        '/details': (context) => DetailsScreen(detailsViewModel: detailsViewModel),
      },
    );
  }
}