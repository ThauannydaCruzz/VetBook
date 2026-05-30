import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

/* Tela de login para donos (tutores de animais).
 * O usuário informa CPF e senha para acessar o app.
 *
 * Fluxo:
 *   1. Usuário digita CPF e senha
 *   2. App chama AuthService.loginDono() — que valida no backend e salva o token
 *   3. Em caso de sucesso, navega para /main (substituindo esta rota)
 *   4. Em caso de erro, exibe mensagem no box vermelho */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores dos campos de texto — guardam o que o usuário digitou
  final _cpfCtrl   = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool _loading = false; // Controla o estado de carregamento do botão "Entrar"
  bool _obscure = true;  // Controla se a senha está oculta ou visível
  String? _error;        // Mensagem de erro exibida ao usuário (null = nenhum erro)

  @override
  void dispose() {
    // Libera os controladores ao sair da tela — evita memory leaks
    _cpfCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  /* Realiza o login.
   * Chamada ao pressionar o botão "Entrar" ou ao dar Enter no campo de senha. */
  Future<void> _login() async {
    final cpf   = _cpfCtrl.text.trim();
    final senha = _senhaCtrl.text;

    // Validação básica no cliente antes de chamar a API
    if (cpf.isEmpty || senha.isEmpty) {
      setState(() => _error = 'Preencha o CPF e a senha.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      // Chama o serviço de autenticação — faz a requisição e salva o token localmente
      await AuthService.loginDono(cpf, senha);
      if (!mounted) return;
      // Login bem-sucedido — substitui a rota de login pela tela principal
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      // Exibe a mensagem de erro da exceção (ex: "CPF ou senha incorretos")
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo cobrindo toda a tela
          Positioned.fill(
            child: Image.asset('assets/fundoFolhas.jpg', fit: BoxFit.cover),
          ),
          // Overlay semitransparente para melhorar a legibilidade do formulário
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE8F5E9).withValues(alpha: 0.85),
            ),
          ),
          // Formulário centralizado com scroll para telas pequenas
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 15, bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo do VetBook
                  Image.asset('assets/logo.png', width: 200, height: 200, fit: BoxFit.contain),
                  const SizedBox(height: 30),

                  // Card branco com o formulário de login
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5)),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Bem-vindo de volta!',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        const Text('Acesse para gerenciar as consultas do seu pet.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        const SizedBox(height: 32),

                        // Box de erro — exibido apenas quando _error não é null
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 13))),
                            ]),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Campo de CPF
                        _buildField('CPF', TablerIcons.id_badge, _cpfCtrl,
                            hint: '000.000.000-00'),
                        const SizedBox(height: 16),

                        // Campo de senha com alternância de visibilidade
                        _buildField('Senha', TablerIcons.lock, _senhaCtrl,
                            obscure: _obscure,
                            suffix: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.textMuted, size: 20),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            )),
                        const SizedBox(height: 28),

                        // Botão de login — mostra spinner durante o carregamento
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          // Desabilita o botão durante o carregamento para evitar cliques duplos
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Entrar',
                                  style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold, fontSize: 15)),
                        ),

                        const SizedBox(height: 24),
                        // Link para o cadastro de novos usuários
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Text('Nao tem uma conta? ',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen())),
                            child: const Text('Cadastre-se',
                                style: TextStyle(color: AppColors.primary,
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* Constrói um campo de texto padronizado com ícone, label e borda.
   * O parâmetro `suffix` permite adicionar um botão ao lado direito
   * (ex: botão de mostrar/ocultar senha). */
  Widget _buildField(String label, IconData icon, TextEditingController ctrl,
      {bool obscure = false, Widget? suffix, String? hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: ctrl,
            obscureText: obscure,
            // Pressionar Enter no teclado virtual dispara o login
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(
              hintText: hint ?? label,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        if (suffix != null) suffix,
      ]),
    );
  }
}
