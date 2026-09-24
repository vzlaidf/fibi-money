import 'package:fibi_money/features/transactions/data/datasources/local_transaction_datasource.dart';
import 'package:fibi_money/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:fibi_money/features/transactions/domain/models/transaction.dart';
import 'package:fibi_money/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Fibi Money BLoC smoke test: renders UI and adds new transaction',
      (WidgetTester tester) async {
    // Usamos un repositorio con datos vacíos para verificar el flujo desde 0
    final emptyDatasource =
        LocalTransactionDatasource(initialData: <Transaction>[]);
    final repository =
        TransactionRepositoryImpl(datasource: emptyDatasource);

    await tester.pumpWidget(MyApp(transactionRepository: repository));
    await tester.pumpAndSettle();

    // 1. Verifica los textos y tarjetas principales
    expect(find.text('Balance Total'), findsOneWidget);
    expect(find.text('Transacciones registradas'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Sin transacciones registradas'), findsOneWidget);

    // 2. Verifica la alternancia de tema con ThemeBloc
    expect(find.text('Claro'), findsOneWidget);
    await tester.tap(find.text('Claro'));
    await tester.pumpAndSettle();
    expect(find.text('Oscuro'), findsOneWidget);

    // 3. Abre el modal de nueva transacción desde el FAB
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Nueva Transacción'), findsOneWidget);

    // 4. Llena los campos del formulario
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Monto'), '350.50');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Concepto / Descripción'),
        'Compra de monitor');

    // 5. Envía el formulario para guardar la transacción
    await tester.tap(find.text('Guardar Transacción'));
    await tester.pumpAndSettle();

    // 6. Verifica que el contador se haya incrementado a 1
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Compra de monitor'), findsOneWidget);
  });
}
