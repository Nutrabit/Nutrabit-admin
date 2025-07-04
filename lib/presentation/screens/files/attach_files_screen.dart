import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/presentation/providers/notification_provider.dart';
import 'package:nutrabit_admin/core/models/notification_model.dart';
import 'package:nutrabit_admin/widgets/drawer.dart';
import '../../providers/file_provider.dart';
import '../../../core/models/file_type.dart';
import '../../../core/services/file_service.dart';
import '../../../core/utils/file_picker_util.dart';
import '../../../core/utils/decorations.dart';

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
    'Recomendaciones': FileType.RECOMMENDATIONS,
    'Mediciones': FileType.MEASUREMENTS,
    "Información Extra": FileType.EXTRA_INFORMATION,
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

  final success = await FileUploaderService.uploadFiles(
    files: files,
    patientId: widget.patientId,
  );

  if (!mounted) return;

  ref.read(fileProvider.notifier).clear();
  setState(() => _isUploading = false);

  final popupStyle = getDefaultPopupStyle();

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: popupStyle.decoration,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            popupStyle.icon,
            const SizedBox(height: 12),
            Text(
              success
                  ? 'Archivos enviados exitosamente'
                  : 'Error enviando archivos',
              style: popupStyle.messageTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: popupStyle.buttonStyle,
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Aceptar', style: popupStyle.buttonTextStyle),
            ),
          ],
        ),
      ),
    ),
  );

    if (success) {
      await _createNotification(Timestamp.now().toDate(), widget.patientId);
    }
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                FileTypeSelector(
                  fileTypes: fileTypes,
                  selectedFiles: files,
                  isUploading: _isUploading,
                  onSelect: _selectFile,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SelectedFilesList(
                    files: files,
                    onRemove: (file) => ref.read(fileProvider.notifier).removeFile(file),
                  ),
                ),
                const SizedBox(height: 16),
                UploadFilesButton(
                  isUploading: _isUploading,
                  hasFiles: files.isNotEmpty,
                  onUpload: _uploadFiles,
                ),
              ],
            ),
          ),
          if (_isUploading) const LoadingOverlay(),
        ],
      ),
    );
  }
}

class FileTypeSelector extends StatelessWidget {
  final Map<String, FileType> fileTypes;
  final List<SelectedFile> selectedFiles;
  final bool isUploading;
  final void Function(String, FileType) onSelect;

  const FileTypeSelector({
    super.key,
    required this.fileTypes,
    required this.selectedFiles,
    required this.isUploading,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: fileTypes.entries.map((entry) {
        final alreadyAdded = selectedFiles.any((f) => f.type == entry.value);
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
            onPressed: isUploading ? null : () => onSelect(entry.key, entry.value),
            icon: Icon(
              alreadyAdded ? Icons.check_circle_outline : Icons.attach_file,
              size: 20,
              color: alreadyAdded ? Colors.green : Colors.black54,
            ),
            label: Text(entry.key, style: const TextStyle(fontSize: 15)),
          ),
        );
      }).toList(),
    );
  }
}

class SelectedFilesList extends StatelessWidget {
  final List<SelectedFile> files;
  final void Function(SelectedFile) onRemove;

  const SelectedFilesList({super.key, required this.files, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const Center(child: Text('No se han seleccionado archivos'));
    }
    return ListView.separated(
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
                builder: (_) => AlertDialog(
                  backgroundColor: defaultAlertDialogStyle.backgroundColor,
                  shape: defaultAlertDialogStyle.shape,
                  contentPadding: defaultAlertDialogStyle.contentPadding,
                  title: Text('Eliminar archivo', style: defaultAlertDialogStyle.titleTextStyle),
                  content: Text('¿Estás seguro de que deseas eliminar el archivo?', style: defaultAlertDialogStyle.contentTextStyle),
                  actions: [
                    ElevatedButton(
                      style: defaultAlertDialogStyle.buttonStyle,
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancelar', style: defaultAlertDialogStyle.buttonTextStyle),
                    ),
                    ElevatedButton(
                      style: defaultAlertDialogStyle.buttonStyle,
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Eliminar', style: defaultAlertDialogStyle.buttonTextStyle),
                    ),
                  ],
                ),
              );
              if (confirm == true) onRemove(f);
            },
          ),
        );
      },
      separatorBuilder: (_, __) => const Divider(),
    );
  }
}

class UploadFilesButton extends StatelessWidget {
  final bool isUploading;
  final bool hasFiles;
  final VoidCallback onUpload;

  const UploadFilesButton({
    super.key,
    required this.isUploading,
    required this.hasFiles,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: hasFiles && !isUploading ? onUpload : null,
        icon: const Icon(Icons.cloud_upload),
        label: Text(
          isUploading ? 'Subiendo...' : 'Subir archivos',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: mainButtonDecoration(), // <- Usamos el estilo reutilizable
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) => Container(
        color: const Color.fromARGB(51, 0, 0, 0),
        child: const Center(child: CircularProgressIndicator()),
      );
}



Future<void> _createNotification(DateTime apptTime, patientID) async {
  
  final model = NotificationModel(
    id: '',
    title: '¡Flor te mandó algo!',
    topic: patientID,
    description: 'Revisá tus archivos.',
    scheduledTime: apptTime,
    endDate: apptTime,
    repeatEvery: 1,
    urlIcon: '',
    cancel: false,
  );

  final notificationService = NotificationService();

  try {
    await notificationService.createNotification(model);
  } catch (e) {
    print(e);
  };
}