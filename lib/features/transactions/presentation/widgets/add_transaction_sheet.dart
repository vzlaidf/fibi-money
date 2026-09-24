import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../app_theme.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/transaction_category.dart';
import '../../domain/models/transaction_type.dart';
import '../bloc/transaction_bloc.dart';

/// Modal interactivo para registrar una nueva transacción (Ingreso o Gasto).
class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionBloc>(),
        child: const AddTransactionSheet(),
      ),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  late TransactionCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = TransactionCategory.forType(_selectedType).first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    if (_selectedType == type) return;
    setState(() {
      _selectedType = type;
      _selectedCategory = TransactionCategory.forType(type).first;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amountText = _amountController.text.replaceAll(',', '.').trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    final newTransaction = Transaction(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      date: DateTime.now(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    context.read<TransactionBloc>().add(TransactionAdded(newTransaction));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;
    final colors = context.financialColors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final availableCategories = TransactionCategory.forType(_selectedType);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXLarge)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra de agarre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                'Nueva Transacción',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Selector de Tipo: Ingreso / Gasto
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment<TransactionType>(
                    value: TransactionType.expense,
                    label: const Text('Gasto'),
                    icon: Icon(Icons.arrow_upward, color: colors.expense),
                  ),
                  ButtonSegment<TransactionType>(
                    value: TransactionType.income,
                    label: const Text('Ingreso'),
                    icon: Icon(Icons.arrow_downward, color: colors.income),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) _onTypeChanged(set.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _selectedType.isIncome
                          ? colors.incomeContainer.withValues(alpha: 0.4)
                          : colors.expenseContainer.withValues(alpha: 0.4);
                    }
                    return null;
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de Monto
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.,]?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Monto',
                  prefixText: r'$ ',
                  prefixStyle: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  hintText: '0.00',
                ),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un monto válido';
                  }
                  final val = double.tryParse(value.replaceAll(',', '.'));
                  if (val == null || val <= 0) {
                    return 'El monto debe ser mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Campo de Título
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Concepto / Descripción',
                  hintText: 'Ej. Supermercado, Nómina, Cine',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un concepto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<TransactionCategory>(
                key: ValueKey(_selectedType),
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                ),
                items: availableCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, size: 20, color: colorScheme.primary),
                        const SizedBox(width: 10),
                        Text(category.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (cat) {
                  if (cat != null) {
                    setState(() => _selectedCategory = cat);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Nota opcional
              TextFormField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nota (Opcional)',
                  hintText: 'Detalles adicionales...',
                ),
              ),
              const SizedBox(height: 20),

              // Botón Guardar
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: const Text('Guardar Transacción'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
