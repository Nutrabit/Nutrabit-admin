import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrabit_admin/core/utils/utils.dart';

void main() {
  testWidgets('showCustomDialog muestra y cierra correctamente',
      (WidgetTester tester) async {
    bool wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showCustomDialog(
                    context: context,
                    message: 'Mensaje test',
                    buttonText: 'Continuar',
                    buttonColor: Colors.blue,
                    onPressed: () {
                      wasPressed = true;
                      Navigator.of(context).pop();
                    },
                  );
                },
                child: const Text('Abrir diálogo'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap para abrir el diálogo
    await tester.tap(find.text('Abrir diálogo'));
    await tester.pumpAndSettle();

    // Verificar que el AlertDialog se muestra
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Mensaje test'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);

    // Tap en el botón de diálogo
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Verificar que se cerró y que la función fue llamada
    expect(find.byType(AlertDialog), findsNothing);
    expect(wasPressed, isTrue);
  });
}