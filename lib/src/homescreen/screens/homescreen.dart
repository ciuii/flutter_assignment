import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_assignment/src/homescreen/models/journal_entry.dart';
import 'package:flutter_assignment/src/homescreen/repo/journal_repository.dart';
import 'package:flutter_assignment/src/homescreen/viewmodel/homescreen_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key, required this.homescreenViewModel});
  final HomescreenViewModel homescreenViewModel;

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final _formKey = GlobalKey<FormState>();

  Future<String?> imagePicker() async{
    final picker = ImagePicker();
    final XFile photo = await picker.pickImage(source: ImageSource.camera) as XFile;
    return photo.path;

  }

  @override
  void initState() {
    super.initState();
    widget.homescreenViewModel.onLoadEntries();
  }

  void _onAddNewEntry() {
    final moodController = TextEditingController();
    final textController = TextEditingController();
    final sleepHoursController = TextEditingController();
    final exerciseMinutesController = TextEditingController();
    final mealsController = TextEditingController();
    String? selectedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) =>
      StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
                child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("New entry", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      if(selectedImagePath != null)
                        ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                                File(selectedImagePath!),
                                width: 60, height: 60, fit: BoxFit.cover
                        ),
                        )
                      else
                        Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.grey),
                        ),
                      const SizedBox(width: 10,),
                      TextButton.icon(
                        icon: const Icon(Icons.camera),
                        label: Text(selectedImagePath == null ? "Take photo" : "Retake"),
                        onPressed: () async {
                          final imagePath = await imagePicker();
                          if(imagePath != null){
                            setSheetState(() {
                              selectedImagePath = imagePath;
                            });
                          }
                        },

                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: moodController,
                    decoration: const InputDecoration(labelText: 'Mood (Required)'),
                    validator: (value) => value!.isEmpty ? 'Mood is required' : null,
                  ),
                  TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: "Thoughts (Required)"),
                    maxLines: 10,
                    validator: (value) => value!.isEmpty ? "Text is required" : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: sleepHoursController,
                          decoration: const InputDecoration(labelText: "Sleep hours"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: exerciseMinutesController,
                          decoration: const InputDecoration(labelText: "Exercise mins"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: mealsController,
                    decoration: const InputDecoration(labelText: "Meals"),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.homescreenViewModel.addEntry(
                            moodController.text,
                            textController.text,
                            sleepHoursController.text,
                            exerciseMinutesController.text,
                            mealsController.text,
                            selectedImagePath,
                          );
                          Navigator.of(context).pop();
                         widget.homescreenViewModel.onLoadEntries();
                        }
                      },
                      child: const Text("Add entry"),
                    )),
                ],
              ),
            ),
                ),
            );
          }
      ),
    );
  }

  void _onDeleteEntry(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.homescreenViewModel.deleteEntry(id);
              Navigator.pop(ctx);
               widget.homescreenViewModel.onLoadEntries();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Journal")),

      body: ListenableBuilder(
        listenable: widget.homescreenViewModel,
        builder: (context, child) {
          if (widget.homescreenViewModel.errorMsg != null) {
            final errorMsg = widget.homescreenViewModel.errorMsg!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMsg),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
              widget.homescreenViewModel.errorMsg = null;
            });
          }
          final state = widget.homescreenViewModel.homescreenState;
          if (state == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = state.entries;

          if (entries.isEmpty) {
            return const Center(child: Text("No entries yet. Add one!"));
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              Widget leadingIcon;
              if (entry.imagePath != null && File(entry.imagePath!).existsSync()) {
                leadingIcon = ClipOval(
                  child: Image.file(
                    File(entry.imagePath!),
                    width: 40, height: 40, fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image),
                  ),
                );
              } else {
                leadingIcon = CircleAvatar(
                  backgroundColor: Colors.deepPurple[50],
                  child: Text(entry.mood.isNotEmpty ? entry.mood.substring(0, 1) : "?"),
                );
              }
              return ListTile(
                title: Text(entry.date),
                subtitle: Text("${entry.mood}: ${entry.text}"),
                leading: leadingIcon,
                trailing: const Icon(Icons.chevron_right),
                onLongPress: () => _onDeleteEntry(entry.id),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/details', arguments: entry.id)
                      .then((_) {
                    widget.homescreenViewModel.onLoadEntries();
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddNewEntry,
        backgroundColor: Colors.deepPurple[100],
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}