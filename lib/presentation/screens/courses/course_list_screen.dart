import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/course_provider.dart';
import '../../../core/models/course_model.dart';

// Pantalla principal de cursos
class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCourses = ref.watch(courseListProvider);

    return Scaffold(
      appBar: AppBar(elevation: 0, centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: asyncCourses.when(
          data: (courses) {
            if (courses.isEmpty) {
              return const Center(child: Text('No hay cursos disponibles.'));
            }
            return ListView.separated(
              itemCount: courses.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                if (index == 0) return const _CourseHeaderImage();
                final course = courses[index - 1];
                return _HoverableCourseCard(course);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: _AddCourseButton(
        onPressed: () async {
          // Se abre la pantalla de creación de curso
          final created = await context.push<bool>('/cursos/crear');
          // Si CourseCreation hizo pop(true), se refresca la lista
          if (created == true) {
            // Invalidate es mejor que refresh porque no vuelve a llamar al método
            ref.invalidate(courseListProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Curso creado correctamente')),
            );
          }
        },
      ),
      // Ubicación del botón flotante
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// Botón flotante para “Agregar curso”
class _AddCourseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddCourseButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Color(0xFFD7F9DE),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: const Icon(Icons.add),
    );
  }
}

// imagen de nutri
class _CourseHeaderImage extends StatelessWidget {
  const _CourseHeaderImage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Image.asset('assets/img/nutriImage.png', height: 140),
        const SizedBox(height: 8),
        const Text(
          '¡Estos son los talleres que estoy dando!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Card con animación al pasar el mouse
class _HoverableCourseCard extends StatefulWidget {
  final Course course;
  const _HoverableCourseCard(this.course);

  @override
  State<_HoverableCourseCard> createState() => _HoverableCourseCardState();
}

class _HoverableCourseCardState extends State<_HoverableCourseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _CourseCard(widget.course),
          ),
        ),
      ),
    );
  }
}

// Card de curso principal
class _CourseCard extends StatelessWidget {
  final Course course;
  const _CourseCard(this.course);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM y, HH:mm', 'es');
    String formatDateRange(DateTime? start, DateTime? end) {
      if (start == null || end == null) return 'No disponible';
      return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          if (course.picture.isNotEmpty)
            _CourseImage(url: course.picture)
          else
            _CourseImage(url: null),
          _GradientOverlay(),
          _ShowHiddenIndicator(
            showCourse: course.showCourse,
            showFrom: course.showFrom,
            showUntil: course.showUntil,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              // Padding para que no quede pegado a los bordes
              padding: const EdgeInsets.all(12.0),
              child: _CardContent(
                course: course,
                formatDateRange: formatDateRange,
              ),
            ),
          ),
          // Menú de opciones del curso
          Positioned(
            top: 8,
            right: 8,
            child: CourseOptionsMenu(course: course),
          ),
        ],
      ),
    );
  }
}

class _CourseImage extends StatelessWidget {
  final String? url;
  const _CourseImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return AspectRatio(aspectRatio: 16 / 9, child: _ErrorPlaceholderImage());
    }
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        url!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ErrorPlaceholderImage(),
        loadingBuilder:
            (context, child, loadingProgress) =>
                loadingProgress == null
                    ? child
                    : const _LoadingPlaceholderImage(),
      ),
    );
  }
}

class _ErrorPlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.broken_image, size: 50)),
    );
  }
}

class _LoadingPlaceholderImage extends StatelessWidget {
  const _LoadingPlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// Contenido dentro del card
class _CardContent extends StatelessWidget {
  final Course course;
  final String Function(DateTime?, DateTime?) formatDateRange;

  const _CardContent({required this.course, required this.formatDateRange});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          course.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inscripción: ${formatDateRange(course.inscriptionStart, course.inscriptionEnd)}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          'Curso: ${formatDateRange(course.courseStart, course.courseEnd)}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (course.inscriptionLink.isNotEmpty == true)
              _LinkButton(
                icon: Icons.how_to_reg,
                label: 'Inscribirse',
                url: course.inscriptionLink,
              ),
            if (course.webPage.isNotEmpty == true)
              _LinkButton(
                icon: Icons.language,
                label: 'Web',
                url: course.webPage,
              ),
          ],
        ),
      ],
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withAlpha((0.65 * 255).round()), // 65% negro abajo
              Colors.transparent, // arriba transparente
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ),
    );
  }
}

class _ShowHiddenIndicator extends StatelessWidget {
  final bool showCourse;
  final DateTime? showFrom;
  final DateTime? showUntil;

  const _ShowHiddenIndicator({
    required this.showCourse,
    required this.showFrom,
    required this.showUntil,
  });

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final ocultoManualmente = showCourse == false;
    final tieneRango = showFrom != null && showUntil != null;
    final fueraDeRango = tieneRango &&
        (ahora.isBefore(showFrom!) || ahora.isAfter(showUntil!));
    if (!ocultoManualmente && !fueraDeRango) {
      return const SizedBox.shrink();
    }
    final label = ocultoManualmente
        ? 'Oculto manualmente'
        : 'Oculto programado. El curso se visualizará entre el ${DateFormat('d MMMM y', 'es').format(showFrom!)} y el ${DateFormat('d MMMM y', 'es').format(showUntil!)}';
    // Si quieres forzar un ancho máximo, añades ConstrainedBox:
    return Positioned(
      top: 8,
      left: 8,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,     
            maxLines: null,        
            overflow: TextOverflow.visible, 
          ),
        ),
      ),
    );
  }
}

// Botones: inscripción y web (evaluarse con flor)
class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _LinkButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        final uri = Uri.parse(url);
        final messenger = ScaffoldMessenger.of(context);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          messenger.showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el enlace')),
          );
        }
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

// Menú hamburguesa del curso
class CourseOptionsMenu extends ConsumerWidget {
  final Course course;
  const CourseOptionsMenu({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (action) async {
        switch (action) {
          case 'editar':
            // Se abre pantalla de edición y esperamos un bool
            final updated = await context.push<bool>(
              '/cursos/editar',
              extra: course, // pasamos el objeto course para no volver a fetch
            );
            //  Si CourseCreation hizo pop(true), refrescamos la lista
            if (updated == true) {
              ref.invalidate(courseListProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Curso actualizado correctamente'),
                ),
              );
            }
            break;
          case 'show':
            await ref.read(courseProvider).updateShowCourse(course.id);
            ref.invalidate(courseListProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  course.showCourse
                      ? 'Curso ocultado correctamente'
                      : 'Curso mostrado correctamente',
                ),
              ),
            );
            break;
          case 'eliminar':
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text('Eliminar curso'),
                    content: const Text(
                      '¿Seguro que quieres eliminar este curso?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Se cierra el popup
                          context.pop();
                          // Se muestra el spinner
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (_) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          );
                          try {
                            // Borra el curso
                            // Verifica si tiene imagen y la borra
                            final imageUrl = course.picture;
                            await ref
                                .read(courseProvider)
                                .deleteCourse(course.id, imageUrl: imageUrl);

                            // Hace refresh de la lista de cursos
                            ref.invalidate(courseListProvider);
                          } catch (e) {
                            debugPrint('Error al eliminar curso: $e');
                          } finally {
                            // Cierra el spinner y vuelve a la lista
                            context.pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Curso eliminado correctamente'),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
            );
            break;
        }
      },
      itemBuilder:
          (_) => [
            const PopupMenuItem(value: 'editar', child: Text('Editar')),
            PopupMenuItem(
              value: 'show',
              child: Text(course.showCourse ? 'Ocultar manualmente' : 'Mostrar manualmente'),
            ),
            const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
          ],
    );
  }
}
