import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutrabit_admin/core/services/user_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/core/utils/decorations.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';

class PatientRegistration extends StatelessWidget {
  const PatientRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Pacientes'),
        leading: const BackButton(),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: PatientRegistrationForm(),
      ),
    );
  }
}

class PatientRegistrationForm extends ConsumerWidget {
  const PatientRegistrationForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final ValueNotifier<bool> emailInvalid = ValueNotifier<bool>(true);
    final ValueNotifier<DateTime?> birthdateNotifier = ValueNotifier(null);
    final TextEditingController heightController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    final ValueNotifier<String?> genderNotifier = ValueNotifier<String?>(null);
    final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Nuevo paciente',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              SizedBox(height: 16),
              NameField(controller: nameController),
              SizedBox(height: 12),
              LastNameField(controller: lastNameController),
              SizedBox(height: 12),
              EmailField(
                controller: emailController,
                isValidEmailNotifier: emailInvalid,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BirthdateField(
                      selectedBirthdayNotifier: birthdateNotifier,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: GenderDropdown(
                      selectedGenderNotifier: genderNotifier,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: HeightField(controller: heightController)),
                  SizedBox(width: 12),
                  Expanded(child: WeightField(controller: weightController)),
                ],
              ),
              SizedBox(height: 12),
              Text(
                '* Campos obligatorios',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
              CreateButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (nameController.text.isEmpty ||
                      lastNameController.text.isEmpty ||
                      emailController.text.isEmpty) {
                    messenger
                      ..hideCurrentSnackBar()
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            'Por favor llená los campos obligatorios.',
                          ),
                        ),
                      );
                    return;
                  } else if (!emailInvalid.value) {
                    messenger
                      ..hideCurrentSnackBar()
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('Por favor ingresá un email válido.'),
                        ),
                      );
                    return;
                  }
                  isLoading.value = true;
                  await createUser(
                    ref: ref,
                    name: nameController.text.trim(),
                    lastName: lastNameController.text.trim(),
                    email: emailController.text.trim(),
                    birthday: birthdateNotifier.value,
                    height: int.tryParse(heightController.text.trim()) ?? 0,
                    weight: int.tryParse(weightController.text.trim()) ?? 0,
                    gender: genderNotifier.value ?? '',
                    context: context,
                    onDone: () => isLoading.value = false,
                  );
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (_, loading, __) {
            if (!loading) return SizedBox.shrink();
            return Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
      ],
    );
  }
}

class NameField extends StatelessWidget {
  final TextEditingController controller;

  const NameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Nombre *',
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class LastNameField extends StatelessWidget {
  final TextEditingController controller;

  const LastNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Apellido *',
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final ValueNotifier<bool> isValidEmailNotifier;

  const EmailField({
    super.key,
    required this.controller,
    required this.isValidEmailNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Email *',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        isValidEmailNotifier.value = isValidEmail(value);
      },
    );
  }
}

class BirthdateField extends StatelessWidget {
  final ValueNotifier<DateTime?> selectedBirthdayNotifier;

  const BirthdateField({super.key, required this.selectedBirthdayNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime?>(
      valueListenable: selectedBirthdayNotifier,
      builder: (context, selectedDate, _) {
        return GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              selectedBirthdayNotifier.value = picked;
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: textFieldDecoration('Nacimiento'),
              readOnly: true,
              controller: TextEditingController(
                text:
                    selectedDate != null
                        ? "${selectedDate.day.toString().padLeft(2, '0')}/"
                            "${selectedDate.month.toString().padLeft(2, '0')}/"
                            "${selectedDate.year}"
                        : '',
              ),
            ),
          ),
        );
      },
    );
  }
}

class GenderDropdown extends StatelessWidget {
  final ValueNotifier<String?> selectedGenderNotifier;

  const GenderDropdown({super.key, required this.selectedGenderNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: selectedGenderNotifier,
      builder: (context, selectedGender, child) {
        return DropdownButtonFormField<String>(
          decoration: textFieldDecoration('Sexo'),
          value: selectedGender,
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Masculino')),
            DropdownMenuItem(value: 'Female', child: Text('Femenino')),
            DropdownMenuItem(value: 'Other', child: Text('Otro')),
          ],
          onChanged: (String? newValue) {
            selectedGenderNotifier.value = newValue;
          },
        );
      },
    );
  }
}

class HeightField extends StatelessWidget {
  final TextEditingController controller;

  const HeightField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: textFieldDecoration('Altura (cm)'),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 3,
      buildCounter:
          (_, {required currentLength, required isFocused, maxLength}) => null,
    );
  }
}

class WeightField extends StatelessWidget {
  final TextEditingController controller;

  const WeightField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: textFieldDecoration('Peso (kg)'),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 3,
      buildCounter:
          (_, {required currentLength, required isFocused, maxLength}) => null,
    );
  }
}

class CreateButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CreateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: mainButtonDecoration(),
        onPressed: onPressed,
        child: const Text(
          'Crear cuenta',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
