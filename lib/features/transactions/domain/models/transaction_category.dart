import 'package:flutter/material.dart';
import 'transaction_type.dart';

/// Categorías financieras soportadas en Fibi Money.
enum TransactionCategory {
  // Categorías de Ingreso
  salary(
    displayName: 'Salario',
    type: TransactionType.income,
    icon: Icons.payments_outlined,
  ),
  investment(
    displayName: 'Inversiones',
    type: TransactionType.income,
    icon: Icons.trending_up,
  ),
  freelance(
    displayName: 'Freelance',
    type: TransactionType.income,
    icon: Icons.laptop_mac,
  ),
  otherIncome(
    displayName: 'Otros ingresos',
    type: TransactionType.income,
    icon: Icons.account_balance_wallet_outlined,
  ),

  // Categorías de Gasto
  food(
    displayName: 'Alimentación',
    type: TransactionType.expense,
    icon: Icons.restaurant_outlined,
  ),
  transport(
    displayName: 'Transporte',
    type: TransactionType.expense,
    icon: Icons.directions_car_outlined,
  ),
  bills(
    displayName: 'Servicios',
    type: TransactionType.expense,
    icon: Icons.receipt_long_outlined,
  ),
  entertainment(
    displayName: 'Ocio',
    type: TransactionType.expense,
    icon: Icons.movie_outlined,
  ),
  shopping(
    displayName: 'Compras',
    type: TransactionType.expense,
    icon: Icons.shopping_bag_outlined,
  ),
  health(
    displayName: 'Salud',
    type: TransactionType.expense,
    icon: Icons.medical_services_outlined,
  ),
  otherExpense(
    displayName: 'Otros gastos',
    type: TransactionType.expense,
    icon: Icons.more_horiz,
  );

  const TransactionCategory({
    required this.displayName,
    required this.type,
    required this.icon,
  });

  final String displayName;
  final TransactionType type;
  final IconData icon;

  /// Retorna las categorías asociadas a un tipo específico.
  static List<TransactionCategory> forType(TransactionType type) {
    return TransactionCategory.values.where((c) => c.type == type).toList();
  }
}
