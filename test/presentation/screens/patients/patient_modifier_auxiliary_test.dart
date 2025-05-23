import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModifier extends StatefulWidget {
  final String id;
  final FirebaseFirestore? firestore;

  const PatientModifier({
    Key? key,
    required this.id,
    this.firestore,
  }) : super(key: key);

  @override
  State<PatientModifier> createState() => _PatientModifierState();
}

class _PatientModifierState extends State<PatientModifier> {
  late final FirebaseFirestore _firestore;

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  final List<String> validGender = ['Masculino', 'Femenino', 'Otro'];
  final List<String> activity = ['Sedentario', 'Ligero', 'Moderado', 'Activo'];

  String? _selectedSex;
  String? _selectedActivity;
  DateTime? _birthDay;
  bool _vegetarian = false;
  bool _vegan = false;

  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _firestore = widget.firestore ?? FirebaseFirestore.instance;
  }

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
      await _firestore.collection('users').doc(widget.id).update({
        'name': _nameController.text,
        'lastname': _lastNameController.text,
        'email': _emailController.text,
        'height': int.tryParse(_heightController.text.trim()) ?? 0,
        'weight': int.tryParse(_weightController.text.trim()) ?? 0,
        'sexo': _selectedSex ?? '',
        'birthday': _birthDay,
        'actividad': _selectedActivity ?? '',
        'vegetariano': _vegetarian,
        'vegano': _vegan,
        'modifiedAt': FieldValue.serverTimestamp(),
        'deletedAt': null,
      });

      _showSuccessPopup();
    } catch (e) {
      print('Error al actualizar paciente: $e');
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
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('users').doc(widget.id).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Paciente no encontrado')));
        }

        final data = snapshot.data!.data()!;

        if (!dataLoaded) {
          _nameController.text = data['name'] ?? '';
          _lastNameController.text = data['lastname'] ?? '';
          _emailController.text = data['email'] ?? '';
          _heightController.text = data['height']?.toString() ?? '';
          _weightController.text = data['weight']?.toString() ?? '';
          _selectedSex = (data['sexo'] ?? '').toString().isNotEmpty ? data['sexo'] : null;
          _birthDay = data['birthday']?.toDate();
          _selectedActivity = data['actividad'] ?? 'Sedentario';
          _vegetarian = data['vegetariano'] ?? false;
          _vegan = data['vegano'] ?? false;

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
                _buildTextField(_emailController, 'Correo', keyboardType: TextInputType.emailAddress),
                Row(
                  children: [
                    Expanded(child: _buildDatePicker(context)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdownSexo()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_heightController, 'Altura (cm)', keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_weightController, 'Peso (kg)', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: activity.contains(_selectedActivity) ? _selectedActivity : null,
                  decoration: _inputDecoration('Nivel de actividad'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  items: activity.map((nivel) => DropdownMenuItem(
                    value: nivel,
                    child: Text(nivel),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedActivity = value),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Vegetariano/a'),
                  value: _vegetarian,
                  onChanged: (value) => setState(() => _vegetarian = value),
                ),
                SwitchListTile(
                  title: const Text('Vegano/a'),
                  value: _vegan,
                  onChanged: (value) => setState(() => _vegan = value),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: _updatePatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 224, 76, 158)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 224, 76, 158)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color.fromARGB(255, 224, 76, 158)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _buildDropdownSexo() {
    return DropdownButtonFormField<String>(
      value: validGender.contains(_selectedSex) ? _selectedSex : null,
      decoration: _inputDecoration('Sexo'),
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      items: validGender.map((sexo) => DropdownMenuItem(
        value: sexo,
        child: Text(sexo),
      )).toList(),
      onChanged: (value) => setState(() => _selectedSex = value),
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
          decoration: _inputDecoration('Fecha de nacimiento'),
        ),
      ),
    );
  }
}
