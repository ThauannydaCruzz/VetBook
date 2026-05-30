import 'package:flutter/material.dart';

/* Widget de cabeçalho customizado exibido no topo da tela principal.
 * Implementa PreferredSizeWidget para funcionar como o parâmetro `appBar` do Scaffold,
 * ou como um Container fixo no topo (como em MainScreen).
 *
 * Exibe o logo do VetBook centralizado sobre um fundo verde claro. */
class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Cor de fundo do cabeçalho — verde claro harmoniza com a paleta do app
      color: const Color.fromARGB(255, 139, 190, 140),
      alignment: Alignment.center,
      child: SafeArea(
        // SafeArea garante que o logo não fique atrás da status bar do celular
        child: Image.asset(
          'assets/VetBook1.png',
          height: 150,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // Define a altura preferida do cabeçalho — usada pelo Scaffold para calcular o layout
  @override
  Size get preferredSize => const Size.fromHeight(80);
}
