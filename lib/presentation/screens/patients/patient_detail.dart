import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import 'patient_modifier.dart';

class PatientDetail extends StatelessWidget {
  final String id;

  const PatientDetail({Key? key, required this.id}) : super(key: key);

  Future<void> updateUserState(String id, bool newState) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'isActive': newState});
      print('Usuario actualizado (isActive: $newState)');
    } catch (e) {
      print('Error al actualizar el estado del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(id).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Paciente no encontrado')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Sin nombre';
        final lastname = data['lastname'] ?? '';
        final completeName = '$name $lastname';
        final email = data['email'] ?? '-';
        final weight = data['weight']?.toString() ?? '-';
        final height = data['height']?.toString() ?? '-';
        final diet = data['dieta'] ?? '-';
        final isActive = data['isActive'] ?? true;
        final profilePic = data['profilePic'];

        final birthdayTimestamp = data['birthday'] as Timestamp?;
        String age = '-';
        if (birthdayTimestamp != null) {
          age = calculateAge(birthdayTimestamp.toDate()).toString();
        }

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month, color: Colors.grey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PatientModifier(id: id)),
                  );
                },
              ),
            ],
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PatientModifier(id: id)),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: profilePic != null && profilePic != ''
                                    ? NetworkImage(profilePic)
                                    : const AssetImage('assets/images/avatar.png') as ImageProvider,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(completeName,
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(email, style: const TextStyle(color: Colors.black54)),
                                    const Divider(),
                                    Text('Edad: $age', style: const TextStyle(color: Colors.black54)),
                                    const Divider(),
                                    Text('$weight kg / $height cm',
                                        style: const TextStyle(color: Colors.black54)),
                                    const Divider(),
                                    Text(diet, style: const TextStyle(color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      buildButton(context, 'Ver historial de turnos'),
                      const SizedBox(height: 12),
                      buildButton(context, 'Enviar archivos'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                              content: SizedBox(
                                width: 250,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('¿Estás seguro de que deseas ${isActive ? 'deshabilitar' : 'habilitar'} a $name?'),
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
                                            await updateUserState(id, !isActive);
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
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 14,
                                                          ),
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 216, 95, 135),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isActive ? 'Deshabilitar Cuenta' : 'Habilitar Cuenta',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 62),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildButton(BuildContext context, String title) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.pink.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
