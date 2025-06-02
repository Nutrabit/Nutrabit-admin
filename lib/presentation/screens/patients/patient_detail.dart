import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/core/utils/decorations.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import '../../providers/user_provider.dart';
import 'patient_modifier.dart';

class PatientDetail extends ConsumerWidget {
  final String id;
  const PatientDetail({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider(id));

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(appBar: AppBar(), body: Center(child: Text('Error: $e'))),
      data: (snapshot) {
        if (!snapshot.exists) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Paciente no encontrado')));
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Sin nombre';
        final lastname = data['lastname'] ?? '';
        final email = data['email'] ?? '-';
        final weightValue = data['weight'];
        final heightValue = data['height'];
        final isActive = data['isActive'] ?? true;
        final profilePic = data['profilePic'];
        final birthday = _parseDate(data['birthday']);
        final age = birthday != null ? calculateAge(birthday).toString() : '-';
        final weight = (weightValue != null && weightValue != 0) ? weightValue.toString() : '-';
        final height = (heightValue != null && heightValue != 0) ? heightValue.toString() : '-';

        return Scaffold(
          appBar: AppBar(leading: const BackButton(), elevation: 0),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                _InfoCard(
                  name: '$name $lastname',
                  email: email,
                  age: age,
                  weight: weight,
                  height: height,
                  profilePic: profilePic,
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PatientModifier(id: id)),
                  ),
                ),
                const SizedBox(height: 24),
                PatientActions(id: id),
                const SizedBox(height: 32),
                AccountStatusButton(
                  isActive: isActive,
                  name: '$name $lastname',
                  id: id,
                  ref: ref,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime? _parseDate(dynamic birthdayData) {
    if (birthdayData is Timestamp) return birthdayData.toDate();
    if (birthdayData is String) return DateTime.tryParse(birthdayData);
    return null;
  }
}

class _InfoCard extends StatelessWidget {
  final String name, email, age, weight, height;
  final String? profilePic;
  final VoidCallback onEdit;

  const _InfoCard({
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    this.profilePic,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name.split(' ').map((e) => e.capitalize()).join(' ');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(251, 252, 250, 238),
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.fromLTRB(16, 38, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: (profilePic?.isNotEmpty ?? false) ? NetworkImage(profilePic!) : null,
                backgroundColor: Colors.grey[400],
                child: (profilePic?.isEmpty ?? true)
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(email, style: const TextStyle(color: Colors.black54)),
                    const Divider(),
                    Text('Edad: $age', style: const TextStyle(color: Colors.black54)),
                    const Divider(),
                    Text('$weight kg / $height cm', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 5,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 24),
              onPressed: onEdit,
            ),
          ),
        ),
      ],
    );
  }
}
/// Widget con botones de acción para enviar archivos, ver calendario
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
              context.pushNamed(
              'appointments',
              pathParameters: {'id': id},
             );
            },
          ),
        ),
      ],
    );
  }
}


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
      style: mainButtonDecoration(),
      child: Text(
        isActive ? 'deshabilitar cuenta' : 'habilitar cuenta',
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