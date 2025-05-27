import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/presentation/screens/courses/course_creation.dart';
import 'package:nutrabit_admin/presentation/screens/patients/patient_list.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  @override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: Container(
            width: screenWidth,
            decoration: const BoxDecoration(color: Color(0xFFFEECDA)),
            child: Stack(
              children: [
                SvgPicture.asset(
                  'assets/img/encabezadoHome.svg',
                  width: screenWidth,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.08),
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.06),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Image.asset(
                                'assets/img/nutriImage.png',
                                height: 200,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.error_outline,
                                    size: 60,
                                    color: Colors.red,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.09,
                          vertical: screenHeight * 0.02,
                        ),
                        child: SizedBox(
                          height: screenHeight * 0.45, // altura relativa segura
                          child: GridView.count(
                            crossAxisCount: 2,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: screenWidth * 0.05,
                            mainAxisSpacing: screenHeight * 0.02,
                            children: [
                              _menuButton(
                                context,
                                title: 'Pacientes',
                                image: 'assets/img/patientsImage.png',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PatientList(),
                                  ),
                                ),
                              ),
                              _menuButton(
                                context,
                                title: 'Cursos',
                                image: 'assets/img/publicityImage.png',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CourseCreation(),
                                  ),
                                ),
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
              ],
            ),
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
    final screenWidth = MediaQuery.of(context).size.width;
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
                  border: Border.all(
                    color: borderColor,
                    width: 0.5,
                  ), // Borde en la imagen
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    width: screenWidth,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).size.height * 0.015,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
