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
      // Botón flotante para agregar un nuevo curso
      // floatingActionButton: addCourseButton(
      //   onPressed: () {
      //     context.push('/cursos/crear');
      //   },
      // ),
      floatingActionButton: addCourseButton(
        onPressed: () async {
          // 1. Abrimos la pantalla de creación y esperamos un bool
          final created = await context.push<bool>('/cursos/crear');
          // 2. Si CourseCreation hizo pop(true), refrescamos la lista
          if (created == true) {
            ref.refresh(courseListProvider);
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

class addCourseButton extends StatelessWidget {
  final VoidCallback onPressed;
  const addCourseButton({super.key, required this.onPressed});

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
        child: _CourseCard(widget.course),
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
          course.picture != null && course.picture!.isNotEmpty
              ? Image.network(
                course.picture!,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _errorImage(),
                loadingBuilder:
                    (context, child, loadingProgress) =>
                        loadingProgress == null ? child : _loadingImage(),
              )
              : _errorImage(),
          _gradientOverlay(),
          // Genera un "Oculto" si el curso no está visible
          if (!course.isVisibleNow)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Oculto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _CardContent(
              course: course,
              formatDateRange: formatDateRange,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CourseOptionsMenu(course: course),
          ),
        ],
      ),
    );
  }

  Widget _errorImage() => Container(
    height: 240,
    color: Colors.grey[300],
    child: const Center(child: Icon(Icons.broken_image, size: 50)),
  );

  Widget _loadingImage() => Container(
    height: 240,
    color: Colors.grey[300],
    child: const Center(child: CircularProgressIndicator()),
  );

  Widget _gradientOverlay() => Container(
    height: 240,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.black.withAlpha((0.65 * 255).round()),
          Colors.transparent,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
  );
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
        const SizedBox(height: 4),
        if (course.webPage != null)
          Text(
            course.webPage!,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 6),
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
            if (course.inscriptionLink?.isNotEmpty == true)
              _LinkButton(
                icon: Icons.how_to_reg,
                label: 'Inscribirse',
                url: course.inscriptionLink!,
              ),
            if (course.webPage?.isNotEmpty == true)
              _LinkButton(
                icon: Icons.language,
                label: 'Web',
                url: course.webPage!,
              ),
          ],
        ),
      ],
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
          // case 'editar':
          //   // context.push('/cursos/editar/${course.id}');
          //   context.push('/cursos/editar', extra: course);
          //   break;
          case 'editar':
            // 1. Abrimos la pantalla de edición y esperamos un bool
            final updated = await context.push<bool>(
              '/cursos/editar',
              extra: course, // pasamos el objeto course para no volver a fetch
            );
            // 2. Si CourseCreation hizo pop(true), refrescamos la lista
            if (updated == true) {
              ref.refresh(courseListProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Curso actualizado correctamente'),
                ),
              );
            }
            break;
          case 'show':
            await ref.read(courseProvider).updateShowCourse(course.id);
            ref.refresh(courseListProvider);
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
              builder: (_) => AlertDialog(
                title: const Text('Eliminar curso'),
                content: const Text('¿Seguro que quieres eliminar este curso?'),
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
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        // Borra el curso
                        // Verifica si tiene imagen y la borra
                        final imageUrl = course.picture;
                        await ref.read(courseProvider).deleteCourse(
                          course.id,
                          imageUrl: imageUrl,
                        );

                        // Hace refresh de la lista de cursos
                        ref.refresh(courseListProvider);
                      } catch (e) {
                        debugPrint('Error al eliminar curso: $e');
                      } finally {
                        // Cierra el spinner y vuelve a la lista
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Curso eliminado correctamente')),
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
              // child: Text(course.isVisible ? 'Ocultar' : 'Mostrar'),
              child: Text(course.showCourse ? 'Ocultar' : 'Mostrar'),
            ),
            const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
          ],
    );
  }
}
