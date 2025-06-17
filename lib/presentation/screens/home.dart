import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrabit_admin/widgets/drawer.dart';
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
      precacheImage(const AssetImage('assets/img/nutriImage.png'), context),
      precacheImage(const AssetImage('assets/img/patientsImage.png'), context),
      precacheImage(const AssetImage('assets/img/publicityImage.png'), context),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
      extendBodyBehindAppBar: true,
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
          ),
        ],
      ),
      
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
                        onPressed: () => context.push('/listaInteres'),
                        fontSize: screenWidth * 0.035,
                        width: screenWidth * 0.35,
                        imageHeight: screenHeight * 0.11,
                        baseHeight: screenHeight * 0.04,
                      ),
                    ),
                  ],
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                ),
          ),
        ],
      ),
      endDrawer: AppDrawer(),
      backgroundColor: const Color(0xFFFEECDA),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determinamos si estamos en pantalla pequeña o grande
                final isWide = constraints.maxWidth > 800;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Encabezado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Texto saludo
                        Expanded(
                          flex: 3,
                          child: Text(
                            '¡Aloha Flor!',
                            style: TextStyle(
                              fontSize: isWide ? 48 : 32,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Imagen a la derecha (oculta en pantalla pequeña)
                        if (isWide)
                          Expanded(
                            flex: 2,
                            child: Image.asset(
                              'assets/img/nutriImage.png',
                              fit: BoxFit.contain,
                              height: 200,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Grid de botones
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: isWide ? 4 : 2,
                      crossAxisSpacing: 40,
                      mainAxisSpacing: 40,
                      childAspectRatio: 1,
                      children: [
                        Hero(
                          tag: 'homebutton-Pacientes',
                          child: HomeButton(
                            imagePath: 'assets/img/patientsImage.png',
                            text: 'Pacientes',
                            onPressed: () => context.push('/pacientes'),
                            fontSize: 20,
                            width: 250,
                            imageHeight: 120,
                            baseHeight: 40,
                          ),
                        ),
                        Hero(
                          tag: 'homebutton-publicidades',
                          child: HomeButton(
                            imagePath: 'assets/img/publicityImage.png',
                            text: 'Cursos',
                            onPressed: () => context.push('/cursos'),
                            fontSize: 20,
                            width: 250,
                            imageHeight: 120,
                            baseHeight: 40,
                          ),
                        ),
                        Hero(
                          tag: 'homebutton-notifiaciones',
                          child: HomeButton(
                            imagePath: 'assets/img/notificationImage.png',
                            text: 'Notificaciones',
                            onPressed: () => context.push('/notificaciones'),
                            fontSize: 20,
                            width: 250,
                            imageHeight: 120,
                            baseHeight: 40,
                          ),
                        ),
                        Hero(
                          tag: 'homebutton-recomendaciones',
                          child: HomeButton(
                            imagePath: 'assets/img/recomendationImage.png',
                            text: 'Recomendaciones',
                            onPressed: () => context.push('/listaInteres'),
                            fontSize: 20,
                            width: 250,
                            imageHeight: 120,
                            baseHeight: 40,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
