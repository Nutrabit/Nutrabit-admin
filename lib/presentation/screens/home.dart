import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrabit_admin/widgets/homeButton.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomePage> {
  bool _assetsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_assetsLoaded) {
      _precacheAssets();
    }
  }

  Future<void> _precacheAssets() async {
    await Future.wait([
      precachePicture(
        ExactAssetPicture(
          SvgPicture.svgStringDecoderBuilder,
          'assets/img/encabezadoHome.svg',
        ),
        null,
      ),
      precacheImage(
        const AssetImage('assets/img/nutriImage.png'),
        context, 
      ),
      precacheImage(
        const AssetImage('assets/img/patientsImage.png'),
        context,
      ),
      precacheImage(
        const AssetImage('assets/img/publicityImage.png'),
        context,
      ),
      precacheImage(
        const AssetImage('assets/img/notificationImage.png'),
        context,
      ),
      precacheImage(
        const AssetImage('assets/img/recomendationImage.png'),
        context,
      ),
    ]);
    setState(() => _assetsLoaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_assetsLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    if (kIsWeb) {
      return WebHomePage();
    } else {
      return MobileHomePage();
    }
  }
}
class MobileHomePage extends StatelessWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFEECDA),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                'assets/img/encabezadoHome.svg',
                width: screenWidth,

                fit: BoxFit.fitWidth,
              ),
              Positioned(
                top: screenHeight * 0.03,
                left: screenWidth * 0.08,

                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          '¡Aloha Flor!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.25),
                      ],
                    ),

                    Image.asset(
                      'assets/img/nutriImage.png',
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.5,
                    ),
                    SizedBox(width: screenWidth * 0.1),
                  ],
                ),
              ),

              Positioned(
                top: screenHeight * 0.45,
                left: screenWidth * 0.1,
                child: Row(
                  children: [
                    Hero(
                      tag: 'homebutton-Pacientes',
                      child: HomeButton(
                        imagePath: 'assets/img/patientsImage.png',
                        text: 'Pacientes',
                        onPressed: () => context.push('/pacientes'),
                        fontSize: screenWidth * 0.035,
                        width: screenWidth * 0.35,
                        imageHeight: screenHeight * 0.11,
                        baseHeight: screenHeight * 0.04,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.1),
                    Hero(
                      tag: 'homebutton-publicidades',
                      child: HomeButton(
                        imagePath: 'assets/img/publicityImage.png',
                        text: 'Cursos',
                        onPressed: () => context.push('/cursos'),
                        fontSize: screenWidth * 0.035,
                        width: screenWidth * 0.35,
                        imageHeight: screenHeight * 0.11,
                        baseHeight: screenHeight * 0.04,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: screenHeight * 0.62,
                left: screenWidth * 0.1,
                child: Row(
                  children: [
                    Hero(
                      tag: 'homebutton-notifiaciones',
                      child: HomeButton(
                        imagePath: 'assets/img/notificationImage.png',
                        text: 'Notificaciones',
                        onPressed: () => context.push('/notificaciones'),
                        fontSize: screenWidth * 0.035,
                        width: screenWidth * 0.35,
                        imageHeight: screenHeight * 0.11,
                        baseHeight: screenHeight * 0.04,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.1),
                    Hero(
                      tag: 'homebutton-recomendaciones',
                      child: HomeButton(
                        imagePath: 'assets/img/recomendationImage.png',
                        text: 'Recomendaciones',
                        onPressed: () => context.push('/calendario'),
                        fontSize: screenWidth * 0.035,
                        width: screenWidth * 0.35,
                        imageHeight: screenHeight * 0.11,
                        baseHeight: screenHeight * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () => context.push('/cambiar-clave'),
                  child: Text(
                    'Cambiar contraseña',
                    style: TextStyle(
                      color: Color.fromRGBO(130, 130, 130, 1),
                      fontSize: screenHeight * 0.015,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebHomePage extends StatelessWidget {
  const WebHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFEECDA),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SvgPicture.asset(
                'assets/img/encabezadoHome.svg',
                width: screenWidth,

                fit: BoxFit.fitWidth,
              ),
              Positioned(
                top: screenHeight * 0.03,
                left: screenWidth * 0.08,

                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          '¡Aloha Flor!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.25),
                      ],
                    ),
                    SizedBox(width: screenWidth * 0.3),
                    Image.asset(
                      'assets/img/nutriImage.png',
                      width: screenWidth * 0.5,
                      height: screenHeight * 0.5,
                    ),
                    
                  ],
                ),
              ),

              Positioned(
                top: screenHeight * 0.32,
                left: screenWidth * 0.1,
                child: Row(
                  children: [
                    Hero(
                      tag: 'homebutton-Pacientes',
                      child: HomeButton(
                        imagePath: 'assets/img/patientsImage.png',
                        text: 'Pacientes',
                        onPressed: () => context.push('/pacientes'),
                        fontSize: screenWidth * 0.02,
                        width: screenWidth * 0.2,
                        imageHeight: screenHeight * 0.2,
                        baseHeight: screenHeight * 0.06,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.1),
                    Hero(
                      tag: 'homebutton-publicidades',
                      child: HomeButton(
                        imagePath: 'assets/img/publicityImage.png',
                        text: 'Cursos',
                        onPressed: () => context.push('/cursos'),
                        fontSize: screenWidth * 0.02,
                        width: screenWidth * 0.2,
                        imageHeight: screenHeight * 0.2,
                        baseHeight: screenHeight * 0.06,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: screenHeight * 0.62,
                left: screenWidth * 0.1,
                child: Row(
                  children: [
                    Hero(
                      tag: 'homebutton-notifiaciones',
                      child: HomeButton(
                        imagePath: 'assets/img/notificationImage.png',
                        text: 'Notificaciones',
                        onPressed: () => context.push('/notificaciones'),
                        fontSize: screenWidth * 0.02,
                        width: screenWidth * 0.2,
                        imageHeight: screenHeight * 0.2,
                        baseHeight: screenHeight * 0.06,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.1),
                    Hero(
                      tag: 'homebutton-recomendaciones',
                      child: HomeButton(
                        imagePath: 'assets/img/recomendationImage.png',
                        text: 'Recomendaciones',
                        onPressed: () => context.push('/calendario'),
                        fontSize: screenWidth * 0.02,
                        width: screenWidth * 0.2,
                        imageHeight: screenHeight * 0.2,
                        baseHeight: screenHeight * 0.06,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () => context.push('/cambiar-clave'),
                  child: Text(
                    'Cambiar contraseña',
                    style: TextStyle(
                      color: Color.fromRGBO(130, 130, 130, 1),
                      fontSize: screenHeight * 0.015,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
