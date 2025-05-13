import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/file_provider.dart';
import '../../../core/models/file_type.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/file_picker_util.dart';

class AttachFilesScreen extends ConsumerStatefulWidget {
  final String patientId;

  const AttachFilesScreen({super.key, required this.patientId});

  @override
  ConsumerState<AttachFilesScreen> createState() => _AttachFilesScreenState();
}

class _AttachFilesScreenState extends ConsumerState<AttachFilesScreen> {
  final Map<String, FileType> fileTypes = {
    'Plan de Alimentación': FileType.MEAL_PLAN,
    'Lista de Compras': FileType.SHOPPING_LIST,
    'Plan de Ejercicios': FileType.EXERCISE_PLAN,
    'Recomendaciones': FileType.RECOMMENDATIONS,
  };

  bool _isUploading = false;

  Future<void> _selectFile(String title, FileType type) async {
    final selectedFile = await pickSelectedFile(type, title);
    if (selectedFile != null) {
      ref.read(fileProvider.notifier).addFile(selectedFile);
    }
  }

  Future<void> _uploadFiles() async {
    final files = ref.read(fileProvider).files;
    setState(() => _isUploading = true);

    await FileUploaderService.uploadFiles(
      files: files,
      patientId: widget.patientId,
      context: context,
    );

    ref.read(fileProvider.notifier).clear();
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(fileProvider).files;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enviar archivos al paciente',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Column(
                  children: fileTypes.entries.map((entry) {
                    final alreadyAdded = files.any((f) => f.type == entry.value);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: alreadyAdded ? Colors.green.shade100 : Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 1,
                        ),
                        onPressed: _isUploading ? null : () => _selectFile(entry.key, entry.value),
                        icon: Icon(
                          alreadyAdded ? Icons.check_circle_outline : Icons.attach_file,
                          size: 20,
                          color: alreadyAdded ? Colors.green : Colors.black54,
                        ),
                        label: Text(entry.key, style: const TextStyle(fontSize: 15)),
                      ),
                    );
                  }).toList(),
                ),

                Expanded(
                  child: files.isEmpty
                      ? const Center(child: Text('No se han seleccionado archivos'))
                      : ListView.separated(
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final f = files[index];
                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(f.title),
                              subtitle: Text(f.name),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Eliminar archivo'),
                                      content: const Text('¿Estás seguro de que deseas eliminar el archivo?'),
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
                                    ref.read(fileProvider.notifier).removeFile(f);
                                  }
                                },
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const Divider(),
                        ),
                ),

                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: files.isEmpty || _isUploading ? null : _uploadFiles,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(
                    _isUploading ? 'Subiendo...' : 'Subir archivos',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(const Size.fromHeight(50)),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey.shade400;
                      }
                      if (states.contains(WidgetState.pressed)) {
                        return const Color.fromARGB(255, 165, 70, 90);
                      }
                      return const Color(0xFFDC607A);
                    }),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    elevation: WidgetStateProperty.all(4),
                  ),
                ),
              ],
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}