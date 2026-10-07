import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_assignment/src/homescreen/models/journal_entry.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ServerJournalRepo {
  static const String baseUrl = 'http://10.89.247.101:8080';
  static const String wsUrl = 'ws://10.89.247.101:8080/ws';

  List<JournalEntry> cachedEntries = [];
  bool isLoaded = false;

  final controller = StreamController<List<JournalEntry>>.broadcast();

  Stream<List<JournalEntry>> get entriesStream => controller.stream;
  WebSocketChannel? channel;

  ServerJournalRepo() {
    initWebSocket();
  }

  void initWebSocket() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    try {
      channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      debugPrint('[CLIENT] WebSocket connected');
      channel!.stream.listen((message) {
        debugPrint('[CLIENT] Received WS message: $message');
        handleWebSocketMessage(message);
      }, onError: (error) {
        debugPrint('[CLIENT] WebSocket error: $error');
      });
    } catch (e) {
      debugPrint('[CLIENT] WebSocket connection failed: $e');
    }
  }

  void handleWebSocketMessage(String message) {
    try {
      final decoded = jsonDecode(message);
      final type = decoded['type'];
      final entry = decoded['entry'];
      if (type == 'create') {
        final newEntry = JournalEntry.fromJson(entry);
        if (!cachedEntries.any((e) => e.id == newEntry.id))
          cachedEntries.add(newEntry);
        else if (type == 'update') {
          final updatedEntry = JournalEntry.fromJson(entry);
          final index = cachedEntries.indexWhere((e) =>
          e.id == updatedEntry.id);
          if (index != -1) {
            cachedEntries[index] = updatedEntry;
          }
        } else if (type == 'delete') {
          final id = entry['id'].toString();
          cachedEntries.removeWhere((e) => e.id == id);
        }
        controller.add(List.from(cachedEntries));
      }
    }
    catch (e) {
      debugPrint('[CLIENT] Error handling WebSocket message: $e');
    }
  }

  Future<List<JournalEntry>> getEntries() async {
    if (isLoaded) {
      controller.add(List.from(cachedEntries));
      debugPrint('[CLIENT] Returning cached entries');
      return List.from(cachedEntries);
    }
    debugPrint('[CLIENT] Loading entries from server');
    try {
      final response = await http.get(Uri.parse('$baseUrl/entries'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        cachedEntries =
            jsonList.map((json) => JournalEntry.fromJson(json)).toList();
        isLoaded = true;
        controller.add(List.from(cachedEntries));
        return List.from(cachedEntries);
      }
      else {
        throw Exception('Failed to load entries: ${response.statusCode}');
      }
    }
    catch (e) {
      debugPrint('[CLIENT] Error loading entries: $e');
      throw Exception('Network error: Could not fetch entries');
    }
  }
  Future<JournalEntry> getEntryById(String id) async {
    try{
      return cachedEntries.firstWhere((entry) => entry.id == id);
    }
    catch(e) {
      throw Exception('Entry not found');
    }
  }
  Future<JournalEntry> createEntry(String mood, String textContent, String? sleepHours, String? exerciseMinutes, String? meals, String? imagePath) async {
    final newEntry = JournalEntry(
      id: '',
      date: DateTime.now().toString().split(' ')[0],
      mood: mood,
      text: textContent,
      sleepHours: int.tryParse(sleepHours ?? ''),
      exerciseMinutes: int.tryParse(exerciseMinutes ?? ''),
      meals: meals,
      imagePath: imagePath,
    );
    debugPrint('[CLIENT] Creating new entry: $newEntry');
    try{
      final response = await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newEntry.toJson()),
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode != 200) {
        throw Exception('Failed to create entry: ${response.statusCode}');
      }
    }
    catch(e){
      debugPrint('[CLIENT] Error creating entry: $e');
      throw Exception('Network error: Could not create entry');
    }
    return newEntry;
  }

  Future<void> deleteEntry(String id) async {
    debugPrint('[CLIENT] Deleting entry with id: $id');
    final response = await http.delete(Uri.parse('$baseUrl/entries/$id'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200 || response.statusCode == 404) {
      cachedEntries.removeWhere((e) => e.id == id);
      controller.add(List.from(cachedEntries));

      if (response.statusCode == 404) {
        debugPrint('[CLIENT] Entry was missing on server. Cleaned up local cache.');
      }
    } else {
      throw Exception('Failed to delete entry: ${response.statusCode}');
    }
  }

  Future<void> updateEntry(String id, String mood, String text, String? sleep, String? exercise, String? meals, String? imagePath) async {
    if (!cachedEntries.any((e) => e.id == id)) return;

    final existing = cachedEntries.firstWhere((e) => e.id == id);

    final updated = existing.copyWith(
      mood: mood,
      text: text,
      sleepHours: int.tryParse(sleep ?? ''),
      exerciseMinutes: int.tryParse(exercise ?? ''),
      meals: meals,
      imagePath: imagePath,
    );


    debugPrint('[CLIENT] Updating entry: $updated');

    final response = await http.put(
      Uri.parse('$baseUrl/entries/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updated.toJson()),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final index = cachedEntries.indexWhere((e) => e.id == id);
      if (index != -1) {
        cachedEntries[index] = updated;
        controller.add(List.from(cachedEntries));
      }
    } else if (response.statusCode == 404) {
      cachedEntries.removeWhere((e) => e.id == id);
      controller.add(List.from(cachedEntries));

      throw Exception('Entry no longer exists on server.');
    } else {
      throw Exception('Failed to update entry: ${response.statusCode}');
    }
  }

}