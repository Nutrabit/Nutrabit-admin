import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrabit_admin/presentation/screens/login.dart';

void main() {
  testWidgets('Renderiza pantalla de login correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Login(),
        ),
      ),
    );

    expect(find.text('Iniciar sesión'), findsOneWidget);

    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Contraseña'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Ingresar'), findsOneWidget);

    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);

    expect(find.textContaining('términos de servicio'), findsOneWidget);
    expect(find.textContaining('política de privacidad'), findsOneWidget);
  });
}
