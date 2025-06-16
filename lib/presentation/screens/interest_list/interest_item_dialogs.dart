import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/presentation/providers/interest_item_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:nutrabit_admin/core/utils/decorations.dart'; // Import de estilos

Future<bool?> showDeleteItemDialog(
    BuildContext context, WidgetRef ref, String itemId) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      bool isLoading = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: defaultAlertDialogStyle.backgroundColor,
            elevation: defaultAlertDialogStyle.elevation,
            shape: defaultAlertDialogStyle.shape,
            titleTextStyle: defaultAlertDialogStyle.titleTextStyle,
            contentTextStyle: defaultAlertDialogStyle.contentTextStyle,
            contentPadding: defaultAlertDialogStyle.contentPadding,
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
                ElevatedButton(
                  style: defaultAlertDialogStyle.buttonStyle,
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text('Cancelar', style: defaultAlertDialogStyle.buttonTextStyle),
                ),
                ElevatedButton(
                  style: defaultAlertDialogStyle.buttonStyle,
                  onPressed: () async {
                    setState(() => isLoading = true);
                    await ref.read(interestItemsProvider.notifier).deleteInterestItem(itemId);
                    if (context.mounted) {
                      Navigator.of(ctx).pop(true);
                    }
                  },
                  child: Text('Eliminar', style: defaultAlertDialogStyle.buttonTextStyle),
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

  return showDialog<void>(
    context: context,
    builder: (ctx) {
      bool isLoading = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: defaultAlertDialogStyle.backgroundColor,
            elevation: defaultAlertDialogStyle.elevation,
            shape: defaultAlertDialogStyle.shape,
            titleTextStyle: defaultAlertDialogStyle.titleTextStyle,
            contentTextStyle: defaultAlertDialogStyle.contentTextStyle,
            contentPadding: defaultAlertDialogStyle.contentPadding,
            title: const Text('Agregar ítem'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: inputDecoration('Título'),
                  autofocus: !kIsWeb,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: inputDecoration('URL', suffix: 'https://...'),
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
                ElevatedButton(
                  style: defaultAlertDialogStyle.buttonStyle,
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancelar', style: defaultAlertDialogStyle.buttonTextStyle),
                ),
                ElevatedButton(
                  style: defaultAlertDialogStyle.buttonStyle,
                  onPressed: () async {
                    final url = urlController.text.trim();
                    final title = titleController.text.trim();
                    if (url.isEmpty || title.isEmpty) return;

                    setState(() => isLoading = true);
                    await ref.read(interestItemsProvider.notifier).addInterestItem(url, title);
                    if (context.mounted) {
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: Text('Confirmar', style: defaultAlertDialogStyle.buttonTextStyle),
                ),
              ],
            ],
          );
        },
      );
    },
  );
}
