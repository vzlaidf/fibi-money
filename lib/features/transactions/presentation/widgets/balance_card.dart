import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../bloc/transaction_bloc.dart';

/// Tarjeta que muestra el Balance Total, los Ingresos y los Gastos acumulados
/// actualizados en tiempo real a través del [TransactionBloc].
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.financialColors;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (previous, current) =>
          previous.balanceSummary != current.balanceSummary ||
          previous.status != current.status,
      builder: (context, state) {
        final summary = state.balanceSummary;
        final totalFormatted = CurrencyFormatter.format(summary.totalBalance);
        final incomeFormatted =
            CurrencyFormatter.formatSigned(summary.totalIncome, isIncome: true);
        final expenseFormatted =
            CurrencyFormatter.formatSigned(summary.totalExpense, isIncome: false);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance Total',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (state.status.isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  totalFormatted,
                  style: AppTypography.currencyHeadline(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.incomeContainer.withValues(alpha: 0.3),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_downward,
                              color: colors.income,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ingresos',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colors.income,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    incomeFormatted,
                                    style: AppTypography.currencySubheadline(
                                      color: colors.income,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.expenseContainer.withValues(alpha: 0.3),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              color: colors.expense,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gastos',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colors.expense,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    expenseFormatted,
                                    style: AppTypography.currencySubheadline(
                                      color: colors.expense,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
