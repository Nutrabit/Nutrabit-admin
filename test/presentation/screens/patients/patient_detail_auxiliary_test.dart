import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_modifier.dart';

bool isRunningTest() {
  return const bool.fromEnvironment('FLUTTER_TEST');
}

class PatientDetail extends StatelessWidget {
  final String id;
  final FirebaseFirestore firestore;


  PatientDetail({
    Key? key,
    required this.id,
    FirebaseFirestore? firestore,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        super(key: key);

  Future<void> updateUserState(String id, bool nuevoEstado) async {
    try {
      await firestore.collection('users').doc(id).update({'isActive': nuevoEstado});
    } catch (e) {
      print('Error al actualizar el estado del usuario: $e');
    }
  }

  int calculateAge(DateTime birthday) {
    final now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: firestore.collection('users').doc(id).snapshots(),
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

        final data = snapshot.data!.data()!;
        final name = data['name'] ?? 'Sin nombre';
        final lastname = data['lastname'] ?? '';
        final completeName = '$name $lastname';
        final email = data['email'] ?? '-';
        final weight = data['weight']?.toString() ?? '-';
        final height = data['height']?.toString() ?? '-';
        final diet = data['dieta'] ?? '-';
        //final isActive = data['isActive'] ?? true;
        //final profilePic = data['profilePic'];

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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            child: isRunningTest() ? const Icon(Icons.person) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(completeName,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(email, style: const TextStyle(color: Colors.black54)),
                                const Divider(),
                                Text('Edad: $age', style: const TextStyle(color: Colors.black54)),
                                const Divider(),
                                Text('$weight kg / $height cm', style: const TextStyle(color: Colors.black54)),
                                const Divider(),
                                Text(diet, style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
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