/* Widget de card para exibir um dono na lista do painel admin.
 * Mostra nome, e-mail e CPF do tutor em um card compacto.
 * Parte da listagem em donos_listar_page.dart. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/dono_model.dart';

/// Card visual de um Dono na listagem administrativa.
class DonoCard extends StatelessWidget {
  final DonoModel dono;

  const DonoCard({super.key, required this.dono});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(children: [
        const CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.person_outline, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dono.nome,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            Text(dono.email,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Text('CPF: ${dono.cpf}',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ]),
        ),
        Text('ID: ${dono.id.substring(0, 8)}...',
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ]),
    );
  }
}
