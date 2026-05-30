import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import '../services/dono_service.dart';
import '../models/dono_model.dart';

/* Tela de cadastro de novo dono/tutor.
 * Após o cadastro bem-sucedido, o login é feito automaticamente —
 * o usuário vai direto para a tela principal sem precisar digitar as credenciais novamente.
 *
 * Validações realizadas antes de chamar a API:
 * - Todos os campos obrigatórios preenchidos
 * - Senha com mínimo de 6 caracteres
 * - Confirmação de senha coincide com a senha digitada */
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para cada campo do formulário
  final _nomeCtrl     = TextEditingController();
  final _cpfCtrl      = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _enderecoCtrl = TextEditingController();
  final _senhaCtrl    = TextEditingController();
  final _confirmaCtrl = TextEditingController(); // Confirmação de senha

  bool _loading      = false; // Bloqueia o botão durante a requisição
  bool _showSenha    = false; // Alterna visibilidade do campo senha
  bool _showConfirma = false; // Alterna visibilidade do campo confirmar senha
  String? _error;             // Mensagem de erro exibida no topo do formulário

  @override
  void dispose() {
    // Libera todos os controladores ao destruir a tela
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    _enderecoCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  /* Realiza o cadastro e login automático.
   * 1. Valida os dados no cliente
   * 2. Chama DonoService.criar() para criar a conta no backend
   * 3. Chama AuthService.loginDono() para salvar o token
   * 4. Navega para /main removendo todas as rotas anteriores (não pode voltar ao cadastro) */
  Future<void> _cadastrar() async {
    final nome     = _nomeCtrl.text.trim();
    final cpf      = _cpfCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final telefone = _telefoneCtrl.text.trim();
    final endereco = _enderecoCtrl.text.trim();
    final senha    = _senhaCtrl.text;
    final confirma = _confirmaCtrl.text;

    // Validações no cliente — evita chamadas desnecessárias à API
    if (nome.isEmpty || cpf.isEmpty || email.isEmpty ||
        telefone.isEmpty || endereco.isEmpty || senha.isEmpty) {
      setState(() => _error = 'Preencha todos os campos obrigatórios.');
      return;
    }
    if (senha.length < 6) {
      setState(() => _error = 'A senha deve ter pelo menos 6 caracteres.');
      return;
    }
    if (senha != confirma) {
      setState(() => _error = 'As senhas não coincidem.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      // Cria o dono no backend — o endpoint não requer autenticação (auth: false)
      await DonoService.criar(CreateDonoRequest(
        nome: nome, cpf: cpf, email: email,
        telefone: telefone, endereco: endereco, senha: senha,
      ));
      // Login automático com as credenciais recém-cadastradas
      await AuthService.loginDono(cpf, senha);
      if (!mounted) return;
      // Navega para o app removendo toda a pilha de rotas (não pode voltar para login/cadastro)
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    } catch (e) {
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
          Positioned.fill(child: Image.asset('assets/fundoFolhas.jpg', fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(color: const Color(0xFFE8F5E9).withValues(alpha: 0.85)),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 15, bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo.png', width: 160, height: 160, fit: BoxFit.contain),
                  const SizedBox(height: 20),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 450),
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
                        // Botão voltar para a tela de login
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(TablerIcons.arrow_left, color: AppColors.primary, size: 20),
                            SizedBox(width: 4),
                            Text('Voltar',
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                        const SizedBox(height: 20),
                        const Text('Crie sua conta',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        const Text('Cadastre-se para agendar os cuidados do seu pet.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        const SizedBox(height: 24),

                        // Box de erro — visível apenas quando há mensagem de erro
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

                        // Campos do formulário de cadastro
                        _field('Nome Completo *', TablerIcons.user, _nomeCtrl),
                        const SizedBox(height: 12),
                        _field('CPF *', TablerIcons.id, _cpfCtrl, hint: '000.000.000-00'),
                        const SizedBox(height: 12),
                        _field('E-mail *', TablerIcons.mail, _emailCtrl),
                        const SizedBox(height: 12),
                        _field('WhatsApp / Telefone *', TablerIcons.phone, _telefoneCtrl),
                        const SizedBox(height: 12),
                        _field('Endereço *', TablerIcons.map_pin, _enderecoCtrl,
                            hint: 'Rua, nº - Cidade/UF'),
                        const SizedBox(height: 12),
                        // Campos de senha com botão para alternar visibilidade
                        _senhaField('Senha *', _senhaCtrl, _showSenha,
                            () => setState(() => _showSenha = !_showSenha)),
                        const SizedBox(height: 12),
                        _senhaField('Confirmar Senha *', _confirmaCtrl, _showConfirma,
                            () => setState(() => _showConfirma = !_showConfirma)),
                        const SizedBox(height: 24),

                        // Botão de cadastro — desabilitado durante o carregamento
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _loading ? null : _cadastrar,
                          child: _loading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Cadastrar e Entrar',
                                  style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
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

  // Campo de texto genérico com ícone e borda
  Widget _field(String label, IconData icon, TextEditingController ctrl, {String? hint}) {
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
            decoration: InputDecoration(
              hintText: hint ?? label,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ]),
    );
  }

  /* Campo de senha com botão para alternar a visibilidade do texto.
   * O parâmetro `toggle` é chamado ao pressionar o ícone do olho. */
  Widget _senhaField(String label, TextEditingController ctrl, bool visible, VoidCallback toggle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(children: [
        const Icon(TablerIcons.lock, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: ctrl,
            obscureText: !visible,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              border: InputBorder.none,
            ),
          ),
        ),
        // Ícone do olho — alterna entre mostrar e ocultar a senha
        GestureDetector(
          onTap: toggle,
          child: Icon(
            visible ? TablerIcons.eye_off : TablerIcons.eye,
            color: AppColors.textMuted,
            size: 20,
          ),
        ),
      ]),
    );
  }
}
