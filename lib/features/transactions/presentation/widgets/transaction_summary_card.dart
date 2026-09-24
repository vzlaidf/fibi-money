import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app_theme.dart';
import '../bloc/transaction_bloc.dart';

/// Tarjeta que muestra el contador de transacciones registradas
/// y controles de filtrado rápido manejados por [TransactionBloc].
class TransactionSummaryCard extends StatelessWidget {
  const TransactionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  'Transacciones registradas',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${state.totalTransactionsCount}',
                  style: AppTypography.currencyHeadline(
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                // Segmentos de filtrado
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: TransactionFilter.values.map((filter) {
                    final isSelected = state.filter == filter;
                    return FilterChip(
                      selected: isSelected,
                      showCheckmark: false,
                      label: Text(filter.label),
                      labelStyle: textTheme.labelSmall?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurfaceVariant,
                      ),
                      backgroundColor:
                          colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      selectedColor: colorScheme.primary,
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      onSelected: (_) {
                        context
                            .read<TransactionBloc>()
                            .add(TransactionFilterChanged(filter));
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tipografía: ${AppTypography.fontFamily}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
