import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import '../../providers/user_provider.dart';
import 'patient_modifier.dart';
import 'package:go_router/go_router.dart';

/// Pantalla principal que muestra el detalle del paciente
class PatientDetail extends ConsumerWidget {
  final String id;

  const PatientDetail({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider(id));

    return userAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error al cargar paciente: $error')),
      ),
      data: (snapshot) {
        if (!snapshot.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Paciente no encontrado')),
          );
        }

        final data = snapshot.data() as Map<String, dynamic>;
        return PatientDetailBody(
          id: id,
          data: data,
          ref: ref,
        );
      },
    );
  }
}

/// Widget que contiene el cuerpo principal del detalle del paciente
class PatientDetailBody extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final WidgetRef ref;

  const PatientDetailBody({
    super.key,
    required this.id,
    required this.data,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final patientInfo = PatientInfo.fromMap(data);

    return PatientDetailLayout(
      patientInfo: patientInfo,
      id: id,
      ref: ref,
    );
  }
}

// Clase simple para datos procesados
class PatientInfo {
  final String completeName;
  final String email;
  final String age;
  final String weight;
  final String height;
  final bool isActive;
  final String? profilePic;

  PatientInfo({
    required this.completeName,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.isActive,
    this.profilePic,
  });

  factory PatientInfo.fromMap(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Sin nombre';
    final lastname = data['lastname'] ?? '';
    final completeName = '$name $lastname';
    final email = data['email'] ?? '-';
    final weight = data['weight']?.toString() ?? '-';
    final height = data['height']?.toString() ?? '-';
    final isActive = data['isActive'] ?? true;
    final profilePic = data['profilePic'];

    // Procesar fecha y calcular edad
    final birthdayData = data['birthday'];
    DateTime? birthdayDate;
    if (birthdayData is Timestamp) {
      birthdayDate = birthdayData.toDate();
    } else if (birthdayData is String) {
      birthdayDate = DateTime.tryParse(birthdayData);
    }
    String age = '-';
    if (birthdayDate != null) {
      age = calculateAge(birthdayDate).toString();
    }

    return PatientInfo(
      completeName: completeName,
      email: email,
      age: age,
      weight: weight,
      height: height,
      isActive: isActive,
      profilePic: profilePic,
    );
  }
}

// Widget que se encarga solo del UI y recibe datos limpios
class PatientDetailLayout extends StatelessWidget {
  final PatientInfo patientInfo;
  final String id;
  final WidgetRef ref;

  const PatientDetailLayout({
    super.key,
    required this.patientInfo,
    required this.id,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: PatientInfoCard(
                completeName: patientInfo.completeName,
                email: patientInfo.email,
                age: patientInfo.age,
                weight: patientInfo.weight,
                height: patientInfo.height,
                profilePic: patientInfo.profilePic,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientModifier(id: id),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PatientActions(id: id),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AccountStatusButton(
                isActive: patientInfo.isActive,
                name: patientInfo.completeName,
                id: id,
                ref: ref,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Widget que muestra la tarjeta con la información del paciente
class PatientInfoCard extends StatelessWidget {
  final String completeName;
  final String email;
  final String age;
  final String weight;
  final String height;
  final String? profilePic;
  final VoidCallback onEdit;

  const PatientInfoCard({
    super.key,
    required this.completeName,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    this.profilePic,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(251, 252, 250, 238),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 15,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: onEdit,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: (profilePic != null && profilePic!.isNotEmpty)
                      ? NetworkImage(profilePic!)
                      : null,
                  backgroundColor: Colors.grey[400],
                  child: (profilePic == null || profilePic!.isEmpty)
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completeName
                            .split(' ')
                            .map((word) => word.capitalize())
                            .join(' '),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const Divider(),
                      Text(
                        'Edad: $age',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const Divider(),
                      Text(
                        '$weight kg / $height cm',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget con botones de acción para enviar archivos, ver calendario, etc.
class PatientActions extends StatelessWidget {
  final String id;

  const PatientActions({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'archivos',
          child: PatientActionButton(
            title: 'Enviar archivos',
            onTap: () {
              context.pushNamed(
                'archivos',
                pathParameters: {'id': id},
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Hero(
          tag: 'calendario',
          child: PatientActionButton(
            title: 'Ver calendario',
            onTap: () {
              context.pushNamed(
                'calendar',
                pathParameters: {'id': id},
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Hero(
          tag: 'historial de turnos',
          child: PatientActionButton(
            title: 'Ver historial de turnos',
            onTap: () {
              // Aquí se puede implementar la navegación a historial de turnos
            },
          ),
        ),
      ],
    );
  }
}

/// Botón para habilitar o deshabilitar la cuenta del paciente, con diálogos de confirmación
class AccountStatusButton extends StatelessWidget {
  final bool isActive;
  final String name;
  final String id;
  final WidgetRef ref;

  const AccountStatusButton({
    super.key,
    required this.isActive,
    required this.name,
    required this.id,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _showConfirmDialog(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDC607A),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        isActive ? 'Deshabilitar Cuenta' : 'Habilitar Cuenta',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          content: SizedBox(
            width: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Estás seguro de que deseas ${isActive ? 'deshabilitar' : 'habilitar'} a $name?',
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text(
                        'CANCELAR',
                        style: TextStyle(fontSize: 14, color: Color(0xFF706B66)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        await ref.read(userProvider.notifier).updateUserState(id, !isActive);
                        _showResultDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFB5D6B2),
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text(
                        'CONFIRMAR',
                        style: TextStyle(fontSize: 14, color: Color(0xFF706B66)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showResultDialog(BuildContext context) {
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
                Text(
                  isActive
                      ? '¡Cuenta deshabilitada correctamente!'
                      : '¡Cuenta habilitada correctamente!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5D6B2),
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    'VOLVER',
                    style: TextStyle(fontSize: 14, color: Color(0xFF706B66)),
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

/// Botón reutilizable para las acciones del paciente
class PatientActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PatientActionButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFDC607A)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
