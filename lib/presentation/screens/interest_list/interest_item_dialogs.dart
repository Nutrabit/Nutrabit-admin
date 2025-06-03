// interest_item_dialogs.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/presentation/providers/interest_item_provider.dart';

Future<void> showDeleteItemDialog(BuildContext context, WidgetRef ref, String itemId) {
  return showDialog(
    context: context,
    builder: (ctx) {
      bool isLoading = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Seguro que quieres eliminar este ítem?'),
            actions: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else ...[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() => isLoading = true);
                    await ref.read(interestItemsProvider.notifier).deleteInterestItem(itemId);
                    if (context.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Eliminar'),
                ),
              ],
            ],
          );
        },
      );
    },
  );
}

Future<void> showAddInterestDialog(BuildContext context, WidgetRef ref) {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  return showDialog(
    context: context,
    builder: (ctx) {
      bool isLoading = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Agregar ítem'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
            actions: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else ...[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    final url = urlController.text.trim();
                    final title = titleController.text.trim();
                    if (url.isEmpty || title.isEmpty) return;

                    setState(() => isLoading = true);

                    await ref.read(interestItemsProvider.notifier).addInterestItem(url, title);
                    if (context.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            ],
          );
        },
      );
    },
  );
}

