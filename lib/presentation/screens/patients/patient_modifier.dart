import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:nutrabit_admin/core/utils/decorations.dart';
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
      final heightText = _heightController.text.trim();
      final weightText = _weightController.text.trim();

      if (heightText.length > 3 || weightText.length > 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Altura y peso deben tener máximo 3 dígitos')),
        );
        return;
      }

      await ref.read(userProvider.notifier).updatePatient(
        id: widget.id,
        name: _nameController.text,
        lastname: _lastNameController.text,
        email: _emailController.text,
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
                const Text('Modificar información',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTextField(_nameController, 'Nombre'),
                _buildTextField(_lastNameController, 'Apellido'),
                _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
                Row(
                  children: [
                    Expanded(child: _buildDatePicker(context)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdownGender()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _heightController,
                        'Altura',
                        keyboardType: TextInputType.number,
                        suffix: 'cm',
                        inputFormatters: [LengthLimitingTextInputFormatter(3)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        _weightController,
                        'Peso',
                        keyboardType: TextInputType.number,
                        suffix: 'kg',
                        inputFormatters: [LengthLimitingTextInputFormatter(3)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: _updatePatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC607A),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Guardar cambios',
                      style: TextStyle(color: Colors.white),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? suffix,
    List<TextInputFormatter>? inputFormatters,
  }) {
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

  Widget _buildDropdownGender() {
    return DropdownButtonFormField<String>(
      value: validGender.contains(_selectedGender) ? _selectedGender : null,
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
      onChanged: (value) => setState(() => _selectedGender = value),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _birthDay ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _birthDay = picked);
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: _birthDay != null
                ? "${_birthDay!.day.toString().padLeft(2, '0')}/${_birthDay!.month.toString().padLeft(2, '0')}/${_birthDay!.year}"
                : '',
          ),
          decoration: inputDecoration('Nacimiento'),
        ),
      ),
    );
  }
}
