/* Dialog de confirmação de exclusão de pet.
 * Exibe uma mensagem pedindo confirmação antes de chamar PetService.remover().
 * A API bloqueia a remoção se o pet tiver consultas futuras. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/pet_model.dart';
import '../../../services/pet_service.dart';

/// Diálogo de confirmação de exclusão de pet.
/// Retorna [true] se o pet foi removido com sucesso.
Future<bool> mostrarExcluirPetDialog(BuildContext context, PetModel pet) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Remover Pet'),
      content: Text(
          'Deseja remover "${pet.nome}"?\nEsta ação não pode ser desfeita.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Remover'),
        ),
      ],
    ),
  );

  if (ok != true) return false;

  try {
    await PetService.remover(pet.id);
    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao remover: $e'),
            backgroundColor: AppColors.error),
      );
    }
    return false;
  }
}
