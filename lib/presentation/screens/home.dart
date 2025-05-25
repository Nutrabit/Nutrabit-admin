import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_list.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEAF5E7), Color(0xFFFFE4E1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 40), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 35),
                        child: Text(
                          '¡Aloha Flor!',
                          style: TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'assets/img/nutriImage.png',
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error_outline, size: 60, color: Colors.red);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 12,
                      children: [
                        _menuButton(
                          context,
                          title: 'Pacientes',
                          image: 'assets/img/patientsImage.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PatientList()),
                            );
                          },
                        ),

                        _menuButton(
                          context,
                          title: 'Publicidades',
                          image: 'assets/img/publicityImage.png',
                          onTap: () {},
                        ),
                        _menuButton(
                          context,
                          title: 'Notificaciones',
                          image: 'assets/img/notificationImage.png',
                          onTap: () {},
                        ),
                        _menuButton(
                          context,
                          title: 'Recomendaciones',
                          image: 'assets/img/recomendationImage.png',
                          onTap: () {},
                        ),
                      ],
                    ),
                    
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/cambiar-clave'),
                    child: const Text(
                      'Cambiar contraseña',
                      style: TextStyle(
                        color: Color.fromRGBO(130, 130, 130, 1),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuButton(
  BuildContext context, {
  required String title,
  required String image,
  required VoidCallback onTap,
}) {
  const Color borderColor = Color(0xFFDC607A);

  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 0.5), // Borde en la imagen
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
