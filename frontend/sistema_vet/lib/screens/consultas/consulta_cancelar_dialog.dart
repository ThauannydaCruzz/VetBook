/* Dialog de cancelamento de consulta.
 * Pede confirmação ao usuário antes de chamar ConsultaService.cancelar().
 * Exibe os dados da consulta para confirmar que é a correta. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/consulta_model.dart';
import '../../../services/consulta_service.dart';

/// Exibe diálogo de confirmação e executa cancelamento da consulta.
/// Retorna [true] se a consulta foi cancelada com sucesso.
Future<bool> mostrarCancelarConsultaDialog(
    BuildContext context, ConsultaModel consulta) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Cancelar Consulta'),
      content: const Text(
          'Tem certeza que deseja cancelar esta consulta?\nEsta ação não pode ser desfeita.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Não'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Cancelar consulta'),
        ),
      ],
    ),
  );

  if (ok != true) return false;

  try {
    await ConsultaService.cancelar(consulta.id, 'Cancelado pelo usuário');
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao cancelar: $e'),
            backgroundColor: AppColors.error),
      );
    }
    return false;
  }
}
