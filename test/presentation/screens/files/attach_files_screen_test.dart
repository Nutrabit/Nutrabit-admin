import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrabit_admin/presentation/screens/files/attach_files_screen.dart';

void main() {
  testWidgets('Renderiza pantalla vacía', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AttachFilesScreen(patientId: 'test123'),
        ),
      ),
    );

    // Verifica título y mensaje
    expect(find.text('Enviar archivos al paciente'), findsOneWidget);
    expect(find.text('No se han seleccionado archivos'), findsOneWidget);
  });
}