import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';

/* Tela de splash — primeira tela exibida ao abrir o app.
 * Enquanto o usuário vê o logo e o slogan, a tela verifica silenciosamente
 * se há um token de sessão válido salvo localmente.
 *
 * Fluxo de navegação:
 *   Token salvo + válido  → /main  (usuário já logado)
 *   Sem token ou inválido → /login (usuário precisa se autenticar) */
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia a verificação de sessão assim que a tela é montada
    _navigate();
  }

  /* Verifica a sessão e navega para a tela correta.
   * Aguarda 2 segundos para exibir o splash antes de redirecionar. */
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Verifica se há um token salvo no armazenamento local
    final tokenSalvo = await AuthService.getToken();
    if (tokenSalvo != null) {
      // Token encontrado — verifica se ainda é válido no servidor
      final valido = await AuthService.validarToken();
      if (!mounted) return;
      if (valido) {
        // Sessão válida — vai direto para o app sem precisar logar novamente
        Navigator.pushReplacementNamed(context, '/main');
        return;
      }
      // Token expirou — validarToken() já limpou os dados locais
    }

    // Sem sessão válida — redireciona para a tela de login
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Imagem de fundo cobrindo toda a tela
          Positioned.fill(
            child: Image.asset('assets/fundoFolhas.jpg', fit: BoxFit.cover),
          ),
          // Overlay semitransparente para suavizar o fundo e melhorar legibilidade
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE8F5E9).withValues(alpha: 0.85),
            ),
          ),
          // Conteúdo centralizado: logo, nome e indicador de carregamento
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo principal do VetBook
                Image.asset('assets/logo.png', width: 220, height: 220, fit: BoxFit.contain),
                const SizedBox(height: 20),
                // Nome do app com fonte cursiva (Google Fonts DancingScript)
                Text(
                  'VetBook',
                  style: GoogleFonts.dancingScript(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Slogan do app
                Text(
                  'Cuidados para o seu melhor amigo!',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                // Indicador circular — mostra que a verificação de sessão está em andamento
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
