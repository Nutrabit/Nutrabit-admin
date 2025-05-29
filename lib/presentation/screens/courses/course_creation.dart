import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/presentation/providers/course_provider.dart';
import 'package:nutrabit_admin/core/utils/decorations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class CourseCreation extends ConsumerStatefulWidget {
  const CourseCreation({super.key});

  @override
  ConsumerState<CourseCreation> createState() => _CourseCreationState();
}

class _CourseCreationState extends ConsumerState<CourseCreation> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _webPage = TextEditingController();
  final ValueNotifier<DateTime?> _startDate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<TimeOfDay?> _startTime = ValueNotifier<TimeOfDay?>(null);
  final ValueNotifier<TimeOfDay?> _endTime = ValueNotifier<TimeOfDay?>(null);
  final TextEditingController _linkController = TextEditingController();
  final ValueNotifier<DateTime?> _inscriptionStart = ValueNotifier(null);
  final ValueNotifier<DateTime?> _inscriptionEnd = ValueNotifier(null);
  final ValueNotifier<DateTime?> _showFrom = ValueNotifier(null);
  final ValueNotifier<DateTime?> _showUntil = ValueNotifier(null);
  final ValueNotifier<Uint8List?> _selectedImage = ValueNotifier<Uint8List?>(
    null,
  );

Future<void> submit() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  try {
    await ref.read(courseProvider).buildAndCreateCourse(
      title: _titleController.text.trim(),
      webPage: _webPage.text.trim(),
      inscriptionLink: _linkController.text.trim(),
      startDate: _startDate.value,
      startTime: _startTime.value,
      endTime: _endTime.value,
      inscriptionStart: _inscriptionStart.value,
      inscriptionEnd: _inscriptionEnd.value,
      showFrom: _showFrom.value,
      showUntil: _showUntil.value,
      imageBytes: _selectedImage.value,
    );

    if (mounted) {
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Curso creado correctamente')),
      );

      _titleController.clear();
      _webPage.clear();
      _linkController.clear();
      _startDate.value = null;
      _startTime.value = null;
      _endTime.value = null;
      _inscriptionStart.value = null;
      _inscriptionEnd.value = null;
      _showFrom.value = null;
      _showUntil.value = null;
      _selectedImage.value = null;
    }
  } on CourseValidationException catch (e) {
    if (mounted) {
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  } catch (e) {
    if (mounted) {
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrio un error')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CourseTitleField(controller: _titleController),
              const SizedBox(height: 12),
              ImagePickerField(selectedImageNotifier: _selectedImage),
              const SizedBox(height: 12),
              WebPageField(controller: _webPage),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fecha del curso o evento',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CourseStartDateField(
                      selectedDateNotifier: _startDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TimeField(
                      label: 'Hora ini',
                      selectedTimeNotifier: _startTime,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TimeField(
                      label: 'Hora fin',
                      selectedTimeNotifier: _endTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Inscripción',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DateTimeField(
                      label: 'Desde',
                      selectedDateTimeNotifier: _inscriptionStart,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DateTimeField(
                      label: 'Hasta',
                      selectedDateTimeNotifier: _inscriptionEnd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CourseInscriptionLinkField(controller: _linkController),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Fechas de visualización de esta publicación',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DateTimeField(
                      label: 'Desde',
                      selectedDateTimeNotifier: _showFrom,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DateTimeField(
                      label: 'Hasta',
                      selectedDateTimeNotifier: _showUntil,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CreateCourseButton(onPressed: submit),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePickerField extends StatelessWidget {
  final ValueNotifier<Uint8List?> selectedImageNotifier;

  const ImagePickerField({super.key, required this.selectedImageNotifier});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      selectedImageNotifier.value = bytes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: selectedImageNotifier,
      builder: (context, imageBytes, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _pickImage(context),
              child:
                  imageBytes == null
                      ? Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Seleccionar imagen',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                      : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 180, 
                              width: double.infinity,
                              child: Image.memory(
                                imageBytes,
                                fit:
                                    BoxFit
                                        .cover, 
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.black,
                              ),
                              onPressed:
                                  () => selectedImageNotifier.value = null,
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        );
      },
    );
  }
}

class CourseTitleField extends StatelessWidget {
  final TextEditingController controller;

  const CourseTitleField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: textFieldDecoration('Título'),
    );
  }
}

class WebPageField extends StatelessWidget {
  final TextEditingController controller;

  const WebPageField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: textFieldDecoration('Link web'),
    );
  }
}

class CourseStartDateField extends StatelessWidget {
  final ValueNotifier<DateTime?> selectedDateNotifier;

  const CourseStartDateField({super.key, required this.selectedDateNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: selectedDateNotifier,
      builder: (context, selectedDate, _) {
        final controller = TextEditingController(
          text:
              selectedDate != null
                  ? "${selectedDate.day.toString().padLeft(2, '0')}/"
                      "${selectedDate.month.toString().padLeft(2, '0')}/"
                      "${selectedDate.year}"
                  : '',
        );

        return TextFormField(
          readOnly: true,
          controller: controller,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              selectedDateNotifier.value = picked;
            }
          },
          decoration: textFieldDecoration('Día').copyWith(
            suffixIcon:
                selectedDate != null
                    ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black),
                      onPressed: () {
                        selectedDateNotifier.value = null;
                      },
                    )
                    : null,
          ),
        );
      },
    );
  }
}

class TimeField extends StatelessWidget {
  final String label;
  final ValueNotifier<TimeOfDay?> selectedTimeNotifier;

  const TimeField({
    super.key,
    required this.label,
    required this.selectedTimeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TimeOfDay?>(
      valueListenable: selectedTimeNotifier,
      builder: (context, selectedTime, _) {
        final controller = TextEditingController(
          text: selectedTime != null ? selectedTime.format(context) : '',
        );

        return TextFormField(
          readOnly: true,
          controller: controller,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: selectedTime ?? TimeOfDay.now(),
            );
            if (picked != null) {
              selectedTimeNotifier.value = picked;
            }
          },
          decoration: textFieldDecoration(label).copyWith(
            suffixIcon:
                selectedTime != null
                    ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black),
                      onPressed: () {
                        selectedTimeNotifier.value = null;
                      },
                    )
                    : null,
          ),
        );
      },
    );
  }
}

class CourseInscriptionLinkField extends StatelessWidget {
  final TextEditingController controller;

  const CourseInscriptionLinkField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: textFieldDecoration('Link de inscripción'),
      keyboardType: TextInputType.url,
    );
  }
}

class DateTimeField extends StatelessWidget {
  final String label;
  final ValueNotifier<DateTime?> selectedDateTimeNotifier;
  final Color? clearIconColor;

  const DateTimeField({
    super.key,
    required this.label,
    required this.selectedDateTimeNotifier,
    this.clearIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: selectedDateTimeNotifier,
      builder: (context, selectedDateTime, _) {
        final controller = TextEditingController(
          text:
              selectedDateTime != null
                  ? "${selectedDateTime.day.toString().padLeft(2, '0')}/"
                      "${selectedDateTime.month.toString().padLeft(2, '0')}/"
                      "${selectedDateTime.year} "
                      "${TimeOfDay.fromDateTime(selectedDateTime).format(context)}"
                  : '',
        );

        return TextFormField(
          readOnly: true,
          controller: controller,
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDateTime ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null) {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime:
                    selectedDateTime != null
                        ? TimeOfDay.fromDateTime(selectedDateTime)
                        : TimeOfDay.now(),
              );

              if (pickedTime != null) {
                final combined = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                selectedDateTimeNotifier.value = combined;
              }
            }
          },
          decoration: textFieldDecoration(label).copyWith(
            suffixIcon:
                selectedDateTime != null
                    ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: clearIconColor ?? Colors.black,
                      ),
                      onPressed: () {
                        selectedDateTimeNotifier.value = null;
                      },
                    )
                    : null,
          ),
        );
      },
    );
  }
}

class CreateCourseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CreateCourseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: mainButtonDecoration(),
        child: const Text('Crear publicación'),
      ),
    );
  }
}
