import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrabit_admin/presentation/providers/file_provider.dart';
import 'package:nutrabit_admin/core/models/file_type.dart';
import 'package:nutrabit_admin/core/services/file_service.dart';
import 'package:nutrabit_admin/core/utils/file_picker_util.dart';
import 'package:nutrabit_admin/presentation/screens/files/attach_files_screen.dart';

class AttachFilesScreen extends ConsumerStatefulWidget {
  final String patientId;
  final Future<SelectedFile?> Function(FileType, String)? onPickFile;

  const AttachFilesScreen({
    super.key,
    required this.patientId,
    this.onPickFile, 
  });

  @override
  ConsumerState<AttachFilesScreen> createState() => _AttachFilesScreenState();
}

class _AttachFilesScreenState extends ConsumerState<AttachFilesScreen> {
  final Map<String, FileType> fileTypes = {
    'Plan de Alimentación': FileType.MEAL_PLAN,
    'Lista de Compras': FileType.SHOPPING_LIST,
    'Plan de Ejercicios': FileType.EXERCISE_PLAN,
    'Recomendaciones': FileType.RECOMMENDATIONS,
    'InBody': FileType.IN_BODY,
  };

  bool _isUploading = false;

  Future<void> _selectFile(String title, FileType type) async {
    final picker = widget.onPickFile ?? pickSelectedFile;
    final selectedFile = await picker(type, title);
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
