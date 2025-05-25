import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';
import 'package:nutrabit_admin/presentation/screens/files/attach_files_screen.dart';
import '../../providers/user_provider.dart';
import 'patient_modifier.dart';
import 'package:go_router/go_router.dart';

class PatientDetail extends ConsumerWidget {
  final String id;

  const PatientDetail({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider(id));

    return userAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, _) => Scaffold(
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
        final name = data['name'] ?? 'Sin nombre';
        final lastname = data['lastname'] ?? '';
        final completeName = '$name $lastname';
        final email = data['email'] ?? '-';
        final weight = data['weight']?.toString() ?? '-';
        final height = data['height']?.toString() ?? '-';
        final isActive = data['isActive'] ?? true;
        final profilePic = data['profilePic'];

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

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month, color: Colors.grey),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientModifier(id: id),
                    ),
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
                                MaterialPageRoute(
                                  builder: (context) => PatientModifier(id: id),
                                ),
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

                                // Si tiene profilePic, lo carga; si no, queda en null
                                backgroundImage:
                                    (profilePic != null &&
                                            profilePic.isNotEmpty)
                                        ? NetworkImage(profilePic)
                                        : null,
                                backgroundColor: Colors.grey[400],
                                // Si no tiene profilePic, muestra un icono
                                child:
                                    (profilePic == null || profilePic.isEmpty)
                                        ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.white,
                                        )
                                        : null, // color de fondo tras el icono

                              ),

                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      completeName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const Divider(),
                                    Text(
                                      'Edad: $age',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const Divider(),
                                    Text(
                                      '$weight kg / $height cm',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                      ),
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      buildButton(context, 'Ver historial de turnos'),
                      const SizedBox(height: 12),
                      // buildButton(context, 'Enviar archivos'),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AttachFilesScreen(patientId: id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56,), // Equivale a height + vertical padding (16 * 2)
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          backgroundColor: Colors.white, // Fondo blanco como el de un contenedor normal
                          elevation:0, // Sin sombra para que se vea plano como un Container
                          side: const BorderSide(
                            color: Color(0xFFDC607A),
                          ), // Borde rosado
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Enviar archivos",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
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
                              contentPadding: const EdgeInsets.fromLTRB(
                                24,
                                20,
                                24,
                                10,
                              ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        OutlinedButton(
                                          onPressed:
                                              () =>
                                                  Navigator.of(
                                                    dialogContext,
                                                  ).pop(),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 12,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            'CANCELAR',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF706B66),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        OutlinedButton(
                                          onPressed: () async {
                                            Navigator.of(dialogContext).pop();
                                            await ref
                                                .read(userProvider.notifier)
                                                .updateUserState(id, !isActive);

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          22,
                                                        ),
                                                  ),
                                                  content: SizedBox(
                                                    width: 250,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          isActive
                                                              ? '¡Cuenta deshabilitada correctamente!'
                                                              : '¡Cuenta habilitada correctamente!',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Divider(),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        OutlinedButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop(),
                                                          style: OutlinedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFFB5D6B2,
                                                                ),
                                                            side:
                                                                const BorderSide(
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 12,
                                                                ),
                                                            minimumSize:
                                                                Size.zero,
                                                            tapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    6,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            'VOLVER',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Color(
                                                                0xFF706B66,
                                                              ),
                                                            ),
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
                                            backgroundColor: const Color(
                                              0xFFB5D6B2,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.black,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          child: const Text(
                                            'CONFIRMAR',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF706B66),
                                            ),
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
                        backgroundColor: const Color(0xFFDC607A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
