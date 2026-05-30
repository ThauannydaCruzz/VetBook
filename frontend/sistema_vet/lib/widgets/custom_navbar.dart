import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/* Barra de navegação inferior customizada com 5 abas.
 * Recebe o índice da aba ativa e um callback para quando o usuário troca de aba.
 *
 * Abas disponíveis (em ordem):
 *   0 - Início:    Tela de boas-vindas com próximas consultas
 *   1 - Meus Pets: Lista de pets do dono logado
 *   2 - Consultas: Histórico e consultas ativas
 *   3 - Perfil:    Dados do usuário logado
 *   4 - Admin:     Painel administrativo (visível para todos, mas com login separado) */
class CustomBottomNavigationBar extends StatelessWidget {
  // Índice da aba atualmente selecionada (0 a 4)
  final int selectedIndex;
  // Callback chamado quando o usuário toca em uma aba
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Fundo levemente esverdeado para diferenciar da área de conteúdo
        color: AppColors.primary.withValues(alpha: 0.1),
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SafeArea(
        // SafeArea na parte inferior garante que a navbar não fique atrás do home indicator (iPhone)
        top: false,
        child: Row(
          children: [
            _buildNavTab(0, Icons.home,                 'Início'),
            _buildNavTab(1, Icons.pets,                 'Meus Pets'),
            _buildNavTab(2, Icons.assignment,           'Consultas'),
            _buildNavTab(3, Icons.person,               'Perfil'),
            _buildNavTab(4, Icons.admin_panel_settings, 'Admin'),
          ],
        ),
      ),
    );
  }

  /* Constrói um item de navegação individual com ícone e label.
   * A aba ativa usa a cor primary; as inativas usam textMuted.
   * Usa Expanded para que todas as abas tenham a mesma largura. */
  Widget _buildNavTab(int index, IconData icon, String label) {
    bool isActive = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          // Fundo transparente para capturar o toque sem cor de fundo extra
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                // Aba ativa → cor primary; inativa → textMuted (cinza-esverdeado)
                color: isActive ? AppColors.primary : AppColors.textMuted,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
