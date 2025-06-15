import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/core/models/course_model.dart';
import 'package:nutrabit_admin/presentation/providers/course_provider.dart';
import 'package:nutrabit_admin/core/utils/decorations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CourseCreationScreen extends ConsumerStatefulWidget {
  final Course? course;
  const CourseCreationScreen({super.key, this.course});

  @override
  ConsumerState<CourseCreationScreen> createState() =>
      _CourseCreationScreenState();
}

class _CourseCreationScreenState extends ConsumerState<CourseCreationScreen> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _webPageController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  // Notifiers
  final ValueNotifier<DateTime?> _startDate = ValueNotifier(null);
  final ValueNotifier<TimeOfDay?> _startTime = ValueNotifier(null);
  final ValueNotifier<TimeOfDay?> _endTime = ValueNotifier(null);
  final ValueNotifier<DateTime?> _inscriptionStart = ValueNotifier(null);
  final ValueNotifier<DateTime?> _inscriptionEnd = ValueNotifier(null);
  final ValueNotifier<DateTime?> _showFrom = ValueNotifier(null);
  final ValueNotifier<DateTime?> _showUntil = ValueNotifier(null);

  final ValueNotifier<Uint8List?> _selectedImage = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    // Si viene un curso, se cargan los datos existentes
    // Si no, se dejan los campos vacíos
    final course = widget.course;
    if (course == null) return;

    _titleController.text = course.title;
    _webPageController.text = course.webPage;
    _linkController.text = course.inscriptionLink;
    // fechas
    if (course.courseStart != null) {
      _startDate.value = course.courseStart;
      _startTime.value = TimeOfDay.fromDateTime(course.courseStart!);
    }
    if (course.courseEnd != null) {
      _endTime.value = TimeOfDay.fromDateTime(course.courseEnd!);
    }
    _inscriptionStart.value = course.inscriptionStart;
    _inscriptionEnd.value = course.inscriptionEnd;
    _showFrom.value = course.showFrom;
    _showUntil.value = course.showUntil;
    // se carga la imagen si existe
    if (course.picture.isNotEmpty) {
      _loadImageFromUrl(course.picture);
    }
  }

  Future<void> _loadImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _selectedImage.value = response.bodyBytes;
      }
    } catch (e) {
      debugPrint('Error cargando imagen: $e');
    }
  }

  Future<void> _submit() async {
    // Spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    //
    try {
      final existing = widget.course;
      if (existing != null) {
        await _updateCourse(existing);
      } else {
        await _createCourse();
      }
      if (!mounted) return;
      context.pop();
      context.pop(true);
    } on CourseValidationException catch (e) {
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ocurrió un error')));
      }
    }
  }

  Future<void> _updateCourse(Course existing) async {
    // Se crean las fechas de inicio y fin del curso y se verifican
    final DateTime? newStart = _buildDateTime(
      _startDate.value,
      _startTime.value,
    );
    final DateTime? newEnd = _buildDateTime(_startDate.value, _endTime.value);

    String provisionalPictureUrl = existing.picture;
    Uint8List? bytesParaSubir = _selectedImage.value;
    // Si el usuario selecciona una imagen nueva, se sube.
    if (_selectedImage.value == null && existing.picture.isNotEmpty) {
      provisionalPictureUrl = '';
    }
    // Se Actualiza el curso con los datos nuevos
    final updatedCourse = Course(
      id: existing.id,
      title: _titleController.text.trim(),
      webPage: _webPageController.text.trim(),
      picture: provisionalPictureUrl,
      courseStart: newStart,
      courseEnd: newEnd,
      inscriptionStart: _inscriptionStart.value,
      inscriptionEnd: _inscriptionEnd.value,
      showFrom: _showFrom.value,
      showUntil: _showUntil.value,
      showCourse: existing.showCourse,
      showInscription: existing.showInscription,
      inscriptionLink: _linkController.text.trim(),
      createdAtParam: existing.createdAt,
      modifiedAtParam: DateTime.now(),
    );

    await ref
        .read(courseProvider)
        .updateCourse(existing.id, updatedCourse, imageBytes: bytesParaSubir);
  }

  Future<void> _createCourse() async {
    await ref
        .read(courseProvider)
        .buildAndCreateCourse(
          title: _titleController.text.trim(),
          webPage: _webPageController.text.trim(),
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
  }

  DateTime? _buildDateTime(DateTime? date, TimeOfDay? time) {
    // Si ninguno de los dos está definido, devuelve null
    if (date == null && time == null) return null;

    // Si ninguno de los dos es null, crea un DateTime
    if (date != null && time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }
    // Si hay alguno null y otro no, lanza una excepción
    throw CourseValidationException(
      'Si define la fecha del curso, debe completar también hora de inicio y hora de fin.',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _webPageController.dispose();
    _linkController.dispose();
    _startDate.dispose();
    _startTime.dispose();
    _endTime.dispose();
    _inscriptionStart.dispose();
    _inscriptionEnd.dispose();
    _showFrom.dispose();
    _showUntil.dispose();
    _selectedImage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.course != null;
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFFEECDA)),
      backgroundColor: const Color(0xFFFEECDA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _TextFieldSection(
                controller: _titleController,
                label: 'Título',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              ImagePickerField(selectedImageNotifier: _selectedImage),
              const SizedBox(height: 16),
              _TextFieldSection(
                controller: _webPageController,
                label: 'Link Web',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              Text(
                'Fecha del curso o evento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
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
                      label: 'Mostrar desde',
                      selectedDateTimeNotifier: _showFrom,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DateTimeField(
                      label: 'Mostrar hasta',
                      selectedDateTimeNotifier: _showUntil,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: mainButtonDecoration(),
                  child: Text(
                    isEditing ? 'Actualizar publicación' : 'Crear publicación',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextFieldSection extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const _TextFieldSection({
    Key? key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: textFieldDecoration(label),
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
                                fit: BoxFit.contain,
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
