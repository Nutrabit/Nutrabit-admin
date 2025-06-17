import 'package:nutrabit_admin/core/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/core/utils/decorations.dart';
import 'package:nutrabit_admin/presentation/providers/notification_provider.dart';
import 'package:nutrabit_admin/core/models/topic.dart';
import 'package:nutrabit_admin/widgets/drawer.dart';

class NotificationCreation extends ConsumerStatefulWidget {
  final NotificationModel? notification;
  const NotificationCreation({super.key, this.notification});

  @override
  ConsumerState<NotificationCreation> createState() =>
      _NotificationCreationScreenState();
}

class _NotificationCreationScreenState
    extends ConsumerState<NotificationCreation> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _urlIconController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _repeatEveryController = TextEditingController();

  final ValueNotifier<DateTime?> _scheduledTime = ValueNotifier(null);
  final ValueNotifier<DateTime?> _endDate = ValueNotifier(null);
  final ValueNotifier<bool> _cancel = ValueNotifier(false);
  final ValueNotifier<bool> _sent = ValueNotifier(false);

  final topic = Topic.values.toList();
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final notification = widget.notification;
    if (notification == null) return;

    _titleController.text = notification.title;
    _descriptionController.text = notification.description;
    _urlIconController.text = notification.urlIcon ?? '';
    _selectedTopic = notification.topic;
    _repeatEveryController.text = notification.repeatEvery?.toString() ?? '';
    _scheduledTime.value = notification.scheduledTime;
    _endDate.value = notification.endDate;
    _cancel.value = notification.cancel;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.notification != null;

    return Scaffold(
      endDrawer: AppDrawer(),
      appBar: AppBar(
        leading: BackButton(),
        centerTitle: true,
        title: Text(isEditing ? 'Editar notificación' : 'Nueva notificación'),
        backgroundColor: const Color(0xFFFEECDA),
        elevation: 0,
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFEECDA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _TextFieldSection(controller: _titleController, label: 'Título'),
              const SizedBox(height: 12),
              _TextFieldSection(
                controller: _descriptionController,
                label: 'Descripción',
              ),
              const SizedBox(height: 12),
              _TopicDropdown(
                selectedTopic: _selectedTopic,
                onChanged: (value) => setState(() => _selectedTopic = value),
                validTopic: topic,
              ),
              const SizedBox(height: 12),
              _TextFieldSection(
                controller: _repeatEveryController,
                label: 'Repetir cada (dias)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DateTimeField(
                label: 'Inicia el',
                selectedDateTimeNotifier: _scheduledTime,
              ),
              const SizedBox(height: 12),
              DateTimeField(
                label: 'Finaliza el',
                selectedDateTimeNotifier: _endDate,
              ),
              const SizedBox(height: 12),
              if (isEditing)
                SwitchListTile(
                  title: const Text('Pausar'),
                  value: _cancel.value,
                  onChanged: (v) => setState(() => _cancel.value = v),
                ),

              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: _submit,
                style: mainButtonDecoration(),
                child: Text(
                  isEditing ? 'Actualizar notificación' : 'Crear notificación',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final topic = _selectedTopic?.trim() ?? '';
    final repeatEvery = int.tryParse(_repeatEveryController.text.trim());
    final urlIcon =
        _urlIconController.text.trim().isNotEmpty
            ? _urlIconController.text.trim()
            : null;
    final scheduledTime = _scheduledTime.value;
    final endDate = _endDate.value;
    final cancel = _cancel.value;

    final model = NotificationModel(
      id: widget.notification?.id ?? '',
      title: title,
      topic: topic.isEmpty ? 'ALL' : topic,
      description: description,
      scheduledTime: scheduledTime!,
      endDate: endDate,
      repeatEvery: repeatEvery,
      urlIcon: urlIcon,
      cancel: cancel,
    );

    final service = ref.read(notificationServiceProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      print(model);
      await service.submitNotification(model);
      if (mounted) {
        Navigator.of(context).pop();
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlIconController.dispose();
    _topicController.dispose();
    _repeatEveryController.dispose();
    _scheduledTime.dispose();
    _endDate.dispose();
    _cancel.dispose();
    _sent.dispose();
    super.dispose();
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
      decoration: inputDecoration(label),
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
          decoration: inputDecoration(label).copyWith(
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

class _TopicDropdown extends StatelessWidget {
  final String? selectedTopic;
  final List<Topic> validTopic;
  final ValueChanged<String?> onChanged;

  const _TopicDropdown({
    required this.selectedTopic,
    required this.onChanged,
    required this.validTopic,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedTopic,
      decoration: inputDecoration('Destino'),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w400,
      ),
      items:
          validTopic.map((topic) {
            return DropdownMenuItem<String>(
              value: topic.name,
              child: Text(topic.description),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }
}
