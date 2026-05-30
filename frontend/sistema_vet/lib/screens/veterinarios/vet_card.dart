/* Widget de card para exibir um veterinário no painel admin.
 * Mostra iniciais (avatar), nome, CRMV, especialidade e nome da clínica.
 * Inclui um Switch para ativar/inativar o veterinário e um botão "Ver Agenda"
 * que abre a VetAgendaScreen com o calendário de consultas do profissional. */
import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/veterinario_model.dart';
import '../../../services/veterinario_service.dart';

/// Card de veterinário com switch ativo/inativo (uso administrativo).
class VetCard extends StatelessWidget {
  final VeterinarioModel vet;
  final VoidCallback onRefresh;

  const VetCard({super.key, required this.vet, required this.onRefresh});

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
        CircleAvatar(
          backgroundColor:
              vet.ativo ? AppColors.primaryLight : const Color(0xFFF0F0F0),
          child: Text(
            vet.iniciais,
            style: TextStyle(
                color: vet.ativo ? AppColors.primary : AppColors.textMuted,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(vet.nome,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            Text('${vet.crmv} · ${vet.especialidade}',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ]),
        ),
        Switch(
          value: vet.ativo,
          activeColor: AppColors.primary,
          onChanged: (val) async {
            try {
              if (val) {
                await VeterinarioService.ativar(vet.id);
              } else {
                await VeterinarioService.inativar(vet.id);
              }
              onRefresh();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Erro: $e'),
                      backgroundColor: AppColors.error),
                );
              }
            }
          },
        ),
      ]),
    );
  }
}
