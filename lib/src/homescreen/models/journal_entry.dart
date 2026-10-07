
import 'package:equatable/equatable.dart';
class JournalEntry extends Equatable{
  const JournalEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.text,
    this.sleepHours,
    this.exerciseMinutes,
    this.meals,
    this.imagePath
  });
  final String id;
  final String date;
  final String mood;
  final String text;
  final int? sleepHours;
  final int? exerciseMinutes;
  final String? meals;
  final String? imagePath;


  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'].toString(),
      date: json['date'] ?? '',
      mood: json['mood'] ?? '',
      text: json['text'] ?? '',
      sleepHours: json['sleepHours'] != null ? int.tryParse(json['sleepHours'].toString()) : null,
      exerciseMinutes: json['exerciseMinutes'] != null ? int.tryParse(json['exerciseMinutes'].toString()) : null,
      meals: json['meals'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'mood': mood,
      'text': text,
      'sleepHours': sleepHours,
      'exerciseMinutes': exerciseMinutes,
      'meals': meals,
      'imagePath': imagePath,
    };
  }

  JournalEntry copyWith({
    String? id,
    String? date,
    String? mood,
    String? text,
    int? sleepHours,
    int? exerciseMinutes,
    String? meals,
    String? imagePath,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      text: text ?? this.text,
      sleepHours: sleepHours ?? this.sleepHours,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      meals: meals ?? this.meals,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props =>
      [id, date, mood, text, sleepHours, exerciseMinutes, meals, imagePath];
}
