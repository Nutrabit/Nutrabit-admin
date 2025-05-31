import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:nutrabit_admin/core/utils/decorations.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import 'package:nutrabit_admin/presentation/providers/user_provider.dart';

class PatientModifier extends ConsumerStatefulWidget {
  final String id;

  const PatientModifier({super.key, required this.id});

  @override
  ConsumerState<PatientModifier> createState() => _PatientModifierState();
}

class _PatientModifierState extends ConsumerState<PatientModifier> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  final List<String> validGender = ['Masculino', 'Femenino', 'Otro'];

  String? _selectedGender;
  String? _selectedActivity;
  DateTime? _birthDay;

  bool dataLoaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _updatePatient() async {
  try {
    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    if (name.isEmpty || lastName.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre, Apellido y Email son obligatorios')),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un email válido')),
      );
      return;
    }

    if (heightText.length > 3 || weightText.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Altura y peso deben tener máximo 3 dígitos')),
      );
      return;
    }

    await ref.read(userProvider.notifier).updatePatient(
      id: widget.id,
      name: name,
      lastname: lastName,
      email: email,
      height: int.tryParse(heightText) ?? 0,
      weight: int.tryParse(weightText) ?? 0,
      gender: _selectedGender ?? '',
      birthday: _birthDay != null ? Timestamp.fromDate(_birthDay!) : null,
      activity: _selectedActivity ?? '',
    );

    _showSuccessPopup();
  } catch (e) {
    print('Error al actualizar paciente: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al actualizar paciente: $e')),
    );
  }
}

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          content: SizedBox(
            width: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¡Perfil modificado exitosamente!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5D6B2),
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'VOLVER',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF706B66),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userSnapshot = ref.watch(userStreamProvider(widget.id));

    return userSnapshot.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
      data: (doc) {
        if (!doc.exists) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Paciente no encontrado')));
        }

        final data = doc.data() as Map<String, dynamic>;

        if (!dataLoaded) {
          _nameController.text = data['name'] ?? '';
          _lastNameController.text = data['lastname'] ?? '';
          _emailController.text = data['email'] ?? '';
          _heightController.text = (data['height'] != null && data['height'] != 0) ? data['height'].toString() : '';
          _weightController.text = (data['weight'] != null && data['weight'] != 0) ? data['weight'].toString() : '';
          _selectedGender = (data['gender'] ?? '').toString().isNotEmpty ? data['gender'] : null;
          _birthDay = data['birthday']?.toDate();
          _selectedActivity = data['activity'];
          dataLoaded = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Modificar paciente'),
            leading: const BackButton(),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
                const SizedBox(height: 16),
                _LabeledTextField(controller: _nameController, label: 'Nombre'),
                _LabeledTextField(controller: _lastNameController, label: 'Apellido'),
                _EmailField(controller: _emailController),
                Row(
                  children: [
                    Expanded(child: _BirthDayPicker(birthDay: _birthDay, onDateChanged: (date) => setState(() => _birthDay = date))),
                    const SizedBox(width: 12),
                    Expanded(child: _GenderDropdown(selectedGender: _selectedGender, onChanged: (value) => setState(() => _selectedGender = value), validGender: validGender)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _LabeledNumberField(
                        controller: _heightController,
                        label: 'Altura',
                        suffix: 'cm',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledNumberField(
                        controller: _weightController,
                        label: 'Peso',
                        suffix: 'kg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: _SaveButton(onPressed: _updatePatient),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widgets modularizados:

class _LabeledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _LabeledTextField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return _CustomTextField(controller: controller, label: label);
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _CustomTextField(
      controller: controller,
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
    );
  }
}
class _LabeledNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;

  const _LabeledNumberField({
    required this.controller,
    required this.label,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return _CustomTextField(
      controller: controller,
      label: label,
      keyboardType: TextInputType.number,
      suffix: suffix,
      inputFormatters: [LengthLimitingTextInputFormatter(3),
      FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? suffix;
  final List<TextInputFormatter>? inputFormatters;

  const _CustomTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.suffix,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        decoration: inputDecoration(label, suffix: suffix),
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  final String? selectedGender;
  final List<String> validGender;
  final ValueChanged<String?> onChanged;

  const _GenderDropdown({
    required this.selectedGender,
    required this.onChanged,
    required this.validGender,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: validGender.contains(selectedGender) ? selectedGender : null,
      decoration: inputDecoration('Sexo'),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      items: validGender
          .map((sexo) => DropdownMenuItem(
                value: sexo,
                child: Text(sexo),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
class _BirthDayPicker extends StatelessWidget {
  final DateTime? birthDay;
  final ValueChanged<DateTime> onDateChanged;

  const _BirthDayPicker({
    required this.birthDay,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: birthDay ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: birthDay != null
                ? "${birthDay!.day.toString().padLeft(2, '0')}/${birthDay!.month.toString().padLeft(2, '0')}/${birthDay!.year}"
                : '',
          ),
          decoration: inputDecoration('Nacimiento'),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: mainButtonDecoration(), // <- Aquí usamos la función directamente
      child: const Text(
        'Guardar cambios',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
