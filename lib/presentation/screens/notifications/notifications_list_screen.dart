import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/core/models/topic.dart';
import 'package:nutrabit_admin/presentation/providers/notification_provider.dart';
import 'package:nutrabit_admin/core/models/notification_model.dart';
import 'package:nutrabit_admin/widgets/drawer.dart';

// Pantalla principal
class NotificationsListScreen extends ConsumerWidget {
  const NotificationsListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trae las notificaciones
    final notificationsAsync = ref.watch(notificationsControllerProvider);
    // Trae el topic seleccionado por el usuario en el filtro
    final selectedTopic = ref.watch(selectedTopicProvider);
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('Notificaciones'),
        backgroundColor: const Color(0xFFFEECDA),
        scrolledUnderElevation: 0,  
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
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (notifications) {
          final allNotifications = notifications;
          // Si hay un topic seleccionado, filtra las notificaciones por ese topic
          final filteredNotifications =
              selectedTopic == null
                  // si no hay selección, muestro todas
                  ? allNotifications
                  // si hay selección, solo las que coincidan con ese Topic
                  : allNotifications.where((n) {
                    return parseTopic(n.topic) == selectedTopic;
                  }).toList();
          return Column(
            children: [
              // Filtro de objetivos/topics
              const TopicFilterDropdown(),
              // Lista de notificaciones
              Expanded(
                child:
                    filteredNotifications.isEmpty
                        ? const Center(child: Text('No hay notificaciones'))
                        : _NotificationsListView(filteredNotifications),
              ),
            ],
          );
        },
      ),
      // Botón para agregar una nueva notificación
      floatingActionButton: const _AddNotificationButton(),
    );
  }
}

// Vista de la lista de notificaciones con lazy loading
class _NotificationsListView extends ConsumerStatefulWidget {
  final List<NotificationModel> notifications;
  const _NotificationsListView(this.notifications);
  @override
  ConsumerState<_NotificationsListView> createState() =>
      _NotificationsListViewState();
}

class _NotificationsListViewState
    extends ConsumerState<_NotificationsListView> {
  final _scrollController = ScrollController();
  late final NotificationsController controller;
  // Flag para mostrar el spinner
  bool _isLoadingMore = false;
  @override
  void initState() {
    super.initState();
    // Obtiene el controlador de notificaciones
    controller = ref.read(notificationsControllerProvider.notifier);
    // Escucha el scroll para cargar más notificaciones
    _scrollController.addListener(_onScroll);
  }

  Future<void> _onScroll() async {
    if (_isLoadingMore || !controller.hasMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      setState(() => _isLoadingMore = true);
      await controller.loadMore();
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.notifications.length + (_isLoadingMore ? 1 : 0),
        padding: const EdgeInsets.symmetric(vertical: 16),
        // Muestra las notificaciones
        itemBuilder: (context, index) {
          if (index < widget.notifications.length) {
            final notification = widget.notifications[index];
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: NotificationRow(notification: notification),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

// Muestra una notificación individual con sus datos
class NotificationRow extends StatelessWidget {
  final NotificationModel notification;
  const NotificationRow({super.key, required this.notification});
  @override
  Widget build(BuildContext context) {
    final topic = parseTopic(notification.topic);
    final descriptionTopic = topic?.description;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Titulo
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC607A),
                  ),
                ),
              ),
              // Menu de opciones
              _NotificationMenu(notification: notification),
            ],
          ),
          const SizedBox(height: 4),
          // Descripción
          Text(
            notification.description,
            style: const TextStyle(fontSize: 15, color: Color(0xFFDC607A)),
          ),
          const SizedBox(height: 8),
          // Info de la notificación
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: 'Objetivo',
                value: descriptionTopic ?? 'error/null',
              ),
              _InfoChip(
                label: 'Desde',
                value: _formatDateTime(notification.scheduledTime),
              ),
              if (notification.endDate != null)
                _InfoChip(
                  label: 'Hasta',
                  value: _formatDateTime(notification.endDate!),
                ),
              if (notification.repeatEvery != null)
                _InfoChip(
                  label: 'Repetir cada',
                  value: '${notification.repeatEvery} días',
                ),
              _InfoChip(
                label: 'Estado',
                value: notification.cancel ? 'Pausada' : 'Activa',
                color:
                    notification.cancel
                        ? const Color.fromARGB(200, 244, 67, 54)
                        : const Color.fromARGB(200, 76, 175, 79),
              ),
            ],
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }

  // Formatea la fecha y hora de una notificación
  static String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// Chip de información para mostrar datos de la notificación
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _InfoChip({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color ?? Colors.white,
      label: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      side: BorderSide(color: color ?? Color(0xFFDC607A), width: 1),
    );
  }
}

// Filtro de objetivos/topics
class TopicFilterDropdown extends ConsumerWidget {
  const TopicFilterDropdown({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTopic = ref.watch(selectedTopicProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: DropdownButton<Topic?>(
            value: selectedTopic,
            onChanged: (value) {
              ref.read(selectedTopicProvider.notifier).state = value;
              ref.read(notificationsControllerProvider.notifier).reset();
            },
            items: [
              const DropdownMenuItem<Topic?>(
                value: null,
                child: Text('Todos los objetivos'),
              ),
              ...Topic.values.map((topic) {
                return DropdownMenuItem<Topic?>(
                  value: topic,
                  child: Text(topic.description),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// Botón para crear notificaciones
class _AddNotificationButton extends ConsumerWidget {
  const _AddNotificationButton();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () async {
        // Espera la respuesta de la creación de la notificación
        final created = await context.push<bool>('/notificaciones/crear');
        // Si viene true, recarga las notificaciones
        if (created == true) {
          ref.read(notificationsControllerProvider.notifier).reset();
        }
      },
      backgroundColor: const Color(0xFFD7F9DE),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: const Icon(Icons.add),
    );
  }
}

// Devuelve el Topic a partir de su nombre, o null si no existe
Topic? parseTopic(String topic) {
  try {
    final cleaned = topic.trim().toUpperCase();
    return Topic.values.firstWhere((e) => e.name == cleaned);
  } catch (_) {
    debugPrint('Error: "$topic" no coincide con ningún objetivo');
    return null;
  }
}

// Clase que representa las opciones del filtro de topics
class TopicOption {
  final Topic? topicKey;
  final String label;

  const TopicOption({required this.topicKey, required this.label});
}

// Menú de opciones en cada notificación
class _NotificationMenu extends ConsumerWidget {
  final NotificationModel notification;
  const _NotificationMenu({required this.notification});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(notificationServiceProvider);

    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          //Editar
          case 'edit':
            final result = await context.push(
              '/notificaciones/editar',
              extra: notification,
            );
            if (result == true && context.mounted) {
              ref.read(notificationsControllerProvider.notifier).reset();
            }
            break;
          // Pausar
          case 'pause':
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            final updated = notification.copyWith(cancel: !notification.cancel);
            await service.updateNotification(updated);
            Navigator.of(context).pop();
            ref.read(notificationsControllerProvider.notifier).reset();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  updated.cancel
                      ? 'Notificación pausada'
                      : 'Notificación reactivada',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
            break;
          // Eliminar
          case 'delete':
            final confirm = await showDialog<bool>(
              context: context,
              builder:
                  // PopUp para eliminar
                  (_) => AlertDialog(
                    title: const Text('¿Eliminar notificación?'),
                    content: const Text('Esta acción no se puede deshacer.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
            );
            if (confirm == true) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (_) => const Center(child: CircularProgressIndicator()),
              );
              await service.deleteNotification(notification.id);
              Navigator.of(context).pop();
              ref.read(notificationsControllerProvider.notifier).reset();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificación eliminada'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            break;
          default:
            debugPrint('Error: $value');
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(
              value: 'pause',
              child: Text(notification.cancel ? 'Activar' : 'Pausar'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
    );
  }
}
