/* Widget de card para exibir um pet na lista.
 * Mostra o emoji da espécie, nome, raça, idade e peso do animal.
 * Inclui botão de excluir que dispara o dialog de confirmação. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/pet_model.dart';

/// Card visual de um Pet na listagem.
class PetCard extends StatelessWidget {
  final PetModel pet;
  final VoidCallback onExcluir;

  const PetCard({super.key, required this.pet, required this.onExcluir});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(pet.emojiEspecie, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pet.nome,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            Text('${pet.especie} · ${pet.raca} · ${pet.idade} anos · ${pet.peso}kg',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            if (pet.observacoes != null && pet.observacoes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(pet.observacoes!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: onExcluir,
        ),
      ]),
    );
  }
}
