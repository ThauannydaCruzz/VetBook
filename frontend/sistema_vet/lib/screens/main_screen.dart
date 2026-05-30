import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_navbar.dart';
import 'main/inicio_page.dart';
import 'main/meus_pets_page.dart';
import 'main/consultas_page.dart';
import 'main/perfil_page.dart';
import 'main/adm_page.dart';

/* Tela principal do app — funciona como um "container" com navegação por abas.
 *
 * Por que IndexedStack em vez de PageView?
 * IndexedStack mantém todas as páginas em memória e apenas esconde/mostra cada uma.
 * Isso preserva o estado (dados carregados, posição do scroll) ao trocar de aba,
 * evitando recarregar os dados da API toda vez que o usuário muda de seção.
 *
 * Abas (índices):
 *   0 - Início:    Boas-vindas + próximas consultas + banner de agendamento
 *   1 - Meus Pets: Lista de pets do dono logado
 *   2 - Consultas: Consultas ativas e histórico com TabBar
 *   3 - Perfil:    Dados do usuário, foto e logout
 *   4 - Admin:     Painel administrativo (com login separado) */
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Índice da aba ativa (começa em 0 = Início)
  int _selectedIndex = 0;

  /* ChangeNotifier usado para coordenar recarregamento entre telas.
   * Quando um agendamento é feito (na tela Início ou no wizard), este
   * notificador avisa a aba de Consultas para recarregar os dados. */
  final _consultasRefresh = ChangeNotifier();

  /* Chamado quando o usuário toca em uma aba da barra de navegação.
   * Ao acessar a aba Consultas (índice 2), dispara um refresh para
   * garantir que a lista está atualizada. */
  void _onTabSelected(int i) {
    if (i == 2) _consultasRefresh.notifyListeners();
    setState(() => _selectedIndex = i);
  }

  @override
  void dispose() {
    // Libera o ChangeNotifier ao destruir a tela — evita memory leaks
    _consultasRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lista de páginas — o índice determina qual é exibida pelo IndexedStack
    final pages = [
      InicioPage(
        onStartBooking: () {},
        // Quando um agendamento é feito na tela inicial, notifica a aba de consultas
        onConsultaAgendada: () => _consultasRefresh.notifyListeners(),
      ),
      const MeusPetsPage(),
      // Passa o notificador para que ConsultasPage saiba quando deve recarregar
      ConsultasPage(refreshNotifier: _consultasRefresh),
      const PerfilPage(),
      const AdmPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho fixo com o logo do VetBook
            const CustomHeader(),
            Expanded(
              // IndexedStack mantém todas as páginas ativas — apenas exibe a selecionada
              child: IndexedStack(
                index: _selectedIndex,
                children: pages,
              ),
            ),
          ],
        ),
      ),
      // Barra de navegação com os 5 ícones das seções
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
