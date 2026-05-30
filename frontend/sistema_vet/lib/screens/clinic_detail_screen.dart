/* Tela de detalhes de uma clínica veterinária.
 * Exibida ao tocar em uma clínica na listagem.
 *
 * IMPORTANTE: Esta tela exibe dados estáticos (placeholder) —
 * ela não recebe um ClinicaModel como parâmetro e não faz chamadas à API.
 * Os dados de serviços e equipe são hard-coded para demonstração.
 * Em uma versão futura, deve receber o ID da clínica e buscar os dados reais.
 *
 * Funcionalidades:
 * - Cabeçalho verde com nome, endereço e ícone da clínica
 * - Seção de serviços disponíveis (badges coloridos)
 * - Seção de equipe veterinária (avatares com iniciais)
 * - Botão "Agendar nesta clínica" — abre o wizard de agendamento */
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:sistema_vet/utils/app_colors.dart';
import 'package:sistema_vet/screens/consultas/agendar_consulta_screen.dart';

class ClinicDetailScreen extends StatelessWidget {
  const ClinicDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: const [
                      Icon(
                        TablerIcons.arrow_left,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Clínicas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🏥', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'CliniPet São Paulo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Av. Paulista, 1500 · Bela Vista · 1,2 km',
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.8 * 255).toInt()),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'SERVIÇOS DISPONÍVEIS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _badgeDetail(
                      '🩺 Consulta General',
                      AppColors.success,
                      AppColors.primaryLight,
                    ),
                    _badgeDetail(
                      '💉 Vacinas V10',
                      AppColors.secondary,
                      const Color(0xFFE8F3FB),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'EQUIPE VETERINÁRIA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _vetAvatar(
                      'AM',
                      'Dra. Ana',
                      'Clínica Geral',
                      AppColors.secondary,
                    ),
                    const SizedBox(width: 16),
                    _vetAvatar(
                      'RC',
                      'Dr. Rui',
                      'Dermatologia',
                      AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          _bottomSafeButton('Agendar nesta clínica →', () {
            // REMOVIDO O CONST INCOERENTE DAQUI
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AgendarConsultaScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _badgeDetail(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _vetAvatar(String initials, String name, String spec, Color bg) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: bg,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          spec,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _bottomSafeButton(String text, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
