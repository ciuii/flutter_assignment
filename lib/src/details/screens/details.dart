import 'dart:io'; // Required for File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_assignment/src/details/viewmodel/details_viewmodel.dart';
import 'package:flutter_assignment/src/homescreen/models/journal_entry.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.detailsViewModel});

  final DetailsViewModel detailsViewModel;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final entryId = ModalRoute.of(context)!.settings.arguments as String;
    widget.detailsViewModel.onLoadEntry(entryId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    return photo?.path;
  }

  void _showEditSheet(JournalEntry entry) {
    final formKey = GlobalKey<FormState>();
    final moodController = TextEditingController(text: entry.mood);
    final textController = TextEditingController(text: entry.text);
    final sleepHoursController = TextEditingController(text: entry.sleepHours?.toString() ?? "");
    final exerciseMinutesController = TextEditingController(text: entry.exerciseMinutes?.toString() ?? "");
    final mealsController = TextEditingController(text: entry.meals ?? "");

    String? currentImagePath = entry.imagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Edit entry", style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        if (currentImagePath != null && currentImagePath!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(currentImagePath!),
                              width: 60, height: 60, fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                            ),
                          )
                        else
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.camera_alt, color: Colors.grey),
                          ),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          icon: const Icon(Icons.camera),
                          label: Text(currentImagePath == null || currentImagePath!.isEmpty ? "Add Photo" : "Retake"),
                          onPressed: () async {
                            final path = await _pickImage();
                            if (path != null) {
                              setSheetState(() {
                                currentImagePath = path;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: moodController,
                      decoration: const InputDecoration(labelText: 'Mood (Required)'),
                      validator: (value) => value!.isEmpty ? 'Mood is required' : null,
                    ),
                    TextFormField(
                      controller: textController,
                      decoration: const InputDecoration(labelText: "Thoughts (Required)"),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? "Text is required" : null,
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: exerciseMinutesController,
                            decoration: const InputDecoration(labelText: "Exercise mins"),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: mealsController,
                      decoration: const InputDecoration(labelText: "Meals"),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            widget.detailsViewModel.updateEntry(
                              entry.id,
                              moodController.text,
                              textController.text,
                              sleepHoursController.text,
                              exerciseMinutesController.text,
                              mealsController.text,
                              currentImagePath!,
                            );
                            widget.detailsViewModel.onLoadEntry(entry.id);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Save changes"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.detailsViewModel,
      builder: (innerContext, child) {
        final state = widget.detailsViewModel.detailsScreenState;

        if (state == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...'), backgroundColor: Colors.deepPurple[100]),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(state.entry.date),
            backgroundColor: Colors.deepPurple[100],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mood: ${state.entry.mood}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(state.entry.text, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),

                // Details Section
                Text("Sleep: ${state.entry.sleepHours ?? '-'} hours"),
                const SizedBox(height: 8),
                Text("Exercise: ${state.entry.exerciseMinutes ?? '-'} minutes"),
                const SizedBox(height: 8),
                Text("Meals: ${state.entry.meals ?? '-'}"),

                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),

                if (state.entry.imagePath != null && state.entry.imagePath!.isNotEmpty) ...[
                  const Text("Attached Photo:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(state.entry.imagePath!),
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(child: Text("Image not found (File moved or deleted)")),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showEditSheet(state.entry),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Entry'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go back'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}