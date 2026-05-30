/* Widget stateless de card de consulta — reutilizável em várias telas.
 * Exibe motivo, data/hora, status (com cor correspondente), nome do pet e veterinário.
 * Recebe a ConsultaModel como parâmetro — toda lógica de negócio fica no chamador. */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../models/consulta_model.dart';

/// Card visual de uma Consulta.
class ConsultaCard extends StatelessWidget {
  final ConsultaModel consulta;
  final bool cancelavel;
  final VoidCallback? onCancelar;

  const ConsultaCard({
    super.key,
    required this.consulta,
    this.cancelavel = false,
    this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (consulta.statusConsulta) {
      case 'Agendada':
        statusColor = AppColors.primary;
        statusIcon  = Icons.schedule;
        break;
      case 'Confirmada':
        statusColor = AppColors.success;
        statusIcon  = Icons.check_circle_outline;
        break;
      case 'Cancelada':
        statusColor = AppColors.error;
        statusIcon  = Icons.cancel_outlined;
        break;
      default:
        statusColor = AppColors.textMuted;
        statusIcon  = Icons.done_all;
    }

    final dtStr =
        DateFormat('dd/MM/yyyy às HH:mm').format(consulta.dataConsulta.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Icon(statusIcon, color: statusColor, size: 16),
            const SizedBox(width: 6),
            Text(consulta.statusConsulta,
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ]),
          Text(dtStr,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ]),
        const Divider(height: 16, color: AppColors.border),
        Row(children: [
          const Icon(Icons.medical_services_outlined,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(consulta.motivoConsulta,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        if (consulta.observacoes != null &&
            consulta.observacoes!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(consulta.observacoes!,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
        if (cancelavel && onCancelar != null) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onCancelar,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancelar', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ]),
    );
  }
}
