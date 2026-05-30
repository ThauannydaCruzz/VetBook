/* Ponto de entrada do aplicativo VetBook.
 * Inicializa a formatação de datas em português brasileiro (pt_BR) antes de
 * iniciar o app — necessário para que intl exiba datas como "segunda-feira, 02/06".
 * Em seguida, executa o widget raiz VetBookApp. */
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/app_colors.dart';
import 'utils/app_navigator.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

/* Função principal assíncrona — obrigatoriamente async porque aguarda
 * a inicialização do binding do Flutter e do locale antes de rodar o app. */
void main() async {
  // Garante que os bindings nativos estejam prontos antes de qualquer operação
  WidgetsFlutterBinding.ensureInitialized();
  // Carrega os símbolos de data em português (nomes de meses, dias da semana, etc.)
  await initializeDateFormatting('pt_BR', null);
  runApp(const VetBookApp());
}

/* Widget raiz do aplicativo — stateless porque a configuração do tema
 * não muda em tempo de execução. */
class VetBookApp extends StatelessWidget {
  const VetBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetBook - Sistema Veterinario',
      debugShowCheckedModeBanner: false,
      // Chave global do navigator — permite navegar de qualquer lugar do app,
      // inclusive de dentro do ApiService (ex: redirecionar ao login após 401)
      navigatorKey: appNavigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        primaryColor: AppColors.primary,
        fontFamily: 'Nunito',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.white,
        ),
      ),
      // Rotas nomeadas — necessárias para navegação global (ex: interceptor 401)
      initialRoute: '/',
      routes: {
        '/':      (context) => const SplashScreen(),   // Splash inicial
        '/login': (context) => const LoginScreen(),    // Tela de login
        '/main':  (context) => const MainScreen(),     // Tela principal após login
      },
    );
  }
}
