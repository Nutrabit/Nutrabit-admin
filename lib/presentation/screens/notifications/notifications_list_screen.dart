import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutrabit_admin/presentation/providers/notification_provider.dart';
import 'package:nutrabit_admin/core/models/notification_model.dart';
import 'package:nutrabit_admin/core/models/goal_model.dart';

class NotificationsListScreen extends ConsumerWidget {
  const NotificationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var notifications = ref.watch(notificationsStreamProvider);
    final selectedTopic = ref.watch(selectedTopicProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: const Color(0xFFFEECDA),
      ),
      backgroundColor: const Color(0xFFFEECDA),
      body: notifications.when(
        data: (notifications) {
          final validNotifications =
              notifications.where((n) {
                return n.topic == 'all' || parseGoalModel(n.topic) != null;
              }).toList();

          final filteredNotifications =
              selectedTopic != null
                  ? validNotifications
                      .where((n) => n.topic == selectedTopic)
                      .toList()
                  : validNotifications;

          return Column(
            children: [
              TopicFilterDropdown(),
              Expanded(
                child:
                    filteredNotifications.isEmpty
                        ? const Center(child: Text('No hay notificaciones'))
                        : _NotificationsListView(filteredNotifications),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: _AddNotificationButton(),
    );
  }
}

class _NotificationsListView extends ConsumerWidget {
  final List<NotificationModel> notifications;

  const _NotificationsListView(this.notifications);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ListView.builder(
        itemCount: notifications.length,
        padding: const EdgeInsets.symmetric(vertical: 16), // opcional
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Center(
            // 👈 Centra la card horizontalmente
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 800,
              ), // 👈 Limita el ancho
              // child: NotificationCard(
              //   notification: notification,
              //   onEdit: () {
              //     print('Editar ${notification.title}');
              //   },
              //   onDelete: () async {
              //     final confirm = await showDialog<bool>(
              //       context: context,
              //       builder:
              //           (_) => AlertDialog(
              //             title: const Text('¿Eliminar notificación?'),
              //             content: const Text(
              //               'Esta acción no se puede deshacer.',
              //             ),
              //             actions: [
              //               TextButton(
              //                 onPressed: () => Navigator.pop(context, false),
              //                 child: const Text('Cancelar'),
              //               ),
              //               TextButton(
              //                 onPressed: () => Navigator.pop(context, true),
              //                 child: const Text('Eliminar'),
              //               ),
              //             ],
              //           ),
              //     );

              //     if (confirm == true) {
              //       await ref
              //           .read(notificationServiceProvider)
              //           .cancelNotification(notification.id);
              //     }
              //   },
              // ),
              child: NotificationRow(
                notification: notification,
              ),
            ),
          );
        },
      ),
    );
  }
}

// class NotificationCard extends StatelessWidget {
//   final NotificationModel notification;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const NotificationCard({
//     super.key,
//     required this.notification,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final goal = parseGoalModel(notification.topic);
//     final objetivoLabel = goal?.description ?? 'General';
//     return Container(
//       decoration: BoxDecoration(
//         // color: Colors.transparent,
//         color: const Color.fromARGB(26, 220, 96, 123),
//         border: Border.all(color: const Color(0xFFDC607A), width: 1.5),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Título y menú
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         notification.title,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           // color: Colors.black,
//                           color: Color.fromARGB(255, 156, 43, 61),
//                         ),
//                       ),
//                     ),
//                     PopupMenuButton<String>(
//                       onSelected: (value) {
//                         if (value == 'edit') {
//                           onEdit();
//                         } else if (value == 'delete') {
//                           onDelete();
//                         }
//                       },
//                       itemBuilder:
//                           (context) => [
//                             const PopupMenuItem(
//                               value: 'edit',
//                               child: Text('Editar'),
//                             ),
//                             const PopupMenuItem(
//                               value: 'delete',
//                               child: Text('Eliminar'),
//                             ),
//                           ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),

//                 // Descripción
//                 Text(
//                   notification.description,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                     // color: Color(0xFF9C2B3D),
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // Info adicional
//                 Wrap(
//                   spacing: 16,
//                   runSpacing: 8,
//                   children: [
//                     _InfoChip(label: 'Objetivo', value: objetivoLabel),
//                     _InfoChip(
//                       label: 'Desde',
//                       value: _formatDateTime(notification.scheduledTime),
//                     ),
//                     if (notification.endDate != null)
//                       _InfoChip(
//                         label: 'Hasta',
//                         value: _formatDateTime(notification.endDate!),
//                       ),
//                     if (notification.repeatEvery != null)
//                       _InfoChip(
//                         label: 'Repetir cada',
//                         value: '${notification.repeatEvery} días',
//                       ),
//                     _InfoChip(
//                       label: 'Estado',
//                       value: notification.cancel ? 'Cancelada' : 'Activa',
//                       color:
//                           notification.cancel
//                               ? const Color.fromARGB(200, 244, 67, 54)
//                               : const Color.fromARGB(200, 76, 175, 79),
//                     ),
//                   ],
//                 ),

//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static String _formatDateTime(DateTime dt) {
//     return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
//   }
// }

class NotificationRow extends StatelessWidget {
  final NotificationModel notification;

  const NotificationRow({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final goal = parseGoalModel(notification.topic);
    final objetivoLabel = goal?.description ?? 'General';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC607A),
                    // color: Color(0xFF9C2B3D),
                  ),
                ),
              ),
              _NotificationMenu(notification: notification,),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            notification.description,
            style: const TextStyle(
              fontSize: 15,
              // color: Colors.black
              color: Color(0xFFDC607A),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Objetivo', value: objetivoLabel),
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

  static String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

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
        style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
      side: BorderSide(color: color ?? Color(0xFFDC607A), width: 1),
    );
  }
}

class TopicFilterDropdown extends ConsumerWidget {
  const TopicFilterDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTopic = ref.watch(selectedTopicProvider);

    // Lista de opciones
    final List<TopicOption> options = [
      const TopicOption(topicKey: null, label: 'Todos los objetivos'),
      const TopicOption(topicKey: 'all', label: 'General'),
      ...GoalModel.values.map(
        (goal) => TopicOption(topicKey: goal.name, label: goal.description),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: DropdownButton<String?>(
            isExpanded: true,
            value: selectedTopic,
            hint: const Text('Filtrar por objetivo'),
            onChanged: (value) {
              ref.read(selectedTopicProvider.notifier).state = value;
            },
            items:
                options.map((opt) {
                  return DropdownMenuItem<String?>(
                    value: opt.topicKey,
                    child: Text(opt.label),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}

class _AddNotificationButton extends StatelessWidget {
  const _AddNotificationButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        context.push('/notificaciones/crear');
      },
      backgroundColor: const Color(0xFFD7F9DE),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: const Icon(Icons.add),
    );
  }
}

GoalModel? parseGoalModel(String topic) {
  try {
    return GoalModel.values.firstWhere((e) => e.name == topic);
  } catch (_) {
    return null;
  }
}

class TopicOption {
  final String? topicKey; // Puede ser 'PERDER_GRASA', 'all', etc.
  final String label;

  const TopicOption({required this.topicKey, required this.label});
}

class _NotificationMenu extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationMenu({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(notificationServiceProvider);

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'edit') {
          context.push('/notificaciones/editar', extra: notification);
        } else if (value == 'pause') {
          final updated = notification.copyWith(cancel: !notification.cancel);
          await service.updateNotification(updated);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(updated.cancel
                ? 'Notificación pausada'
                : 'Notificación reactivada'),
            duration: const Duration(seconds: 2),
          ));
        } else if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
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
            await service.deleteNotification(notification.id);

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Notificación eliminada'),
              duration: Duration(seconds: 2),
            ));
          }
        }
      },
      itemBuilder: (context) => [
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

