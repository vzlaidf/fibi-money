import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/transaction.dart';
import '../bloc/transaction_bloc.dart';

/// Elemento visual que representa una transacción individual en la lista.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final colors = context.financialColors;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    final isIncome = transaction.isIncome;
    final signColor = isIncome ? colors.income : colors.expense;
    final containerColor =
        isIncome ? colors.incomeContainer : colors.expenseContainer;

    final formattedAmount = CurrencyFormatter.formatSignedWholeOrDecimal(
      transaction.amount,
      isIncome: isIncome,
    );

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: colors.expense,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<TransactionBloc>().add(TransactionDeleted(transaction.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transacción "${transaction.title}" eliminada'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Deshacer',
              textColor: Colors.white,
              onPressed: () {
                context
                    .read<TransactionBloc>()
                    .add(TransactionAdded(transaction));
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: colors.borderColor.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icono de categoría
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: containerColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                transaction.category.icon,
                color: signColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Título, categoría y fecha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        transaction.category.displayName,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatDate(transaction.date),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Monto formateado
            Text(
              formattedAmount,
              style: AppTypography.currencySubheadline(
                color: signColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
