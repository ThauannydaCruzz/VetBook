import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../utils/constants.dart';

/* Serviço de autenticação para donos (usuários do app mobile).
 * Gerencia o ciclo de vida da sessão do dono:
 *   1. Login: chama a API, valida a role e salva o token localmente
 *   2. Requisições: recupera o token salvo para incluir no cabeçalho Authorization
 *   3. Logout: remove todos os dados da sessão do armazenamento local
 *
 * SharedPreferences é o armazenamento chave-valor local do Flutter,
 * similar ao localStorage do navegador web. Os dados persistem entre sessões. */
class AuthService {
  // Chaves para identificar cada dado no SharedPreferences
  static const _keyToken   = 'jwt_token';
  static const _keyUsuario = 'usuario';
  static const _keyRole    = 'role';
  static const _keyDonoId  = 'dono_id';

  /* Faz login como dono usando CPF e senha.
   * Após autenticação bem-sucedida, salva o token e os dados da sessão.
   * Lança ApiException se as credenciais forem inválidas ou o usuário não for um dono. */
  static Future<void> loginDono(String cpf, String senha) async {
    final Map<String, dynamic> res;
    try {
      res = await ApiService.post(
        ApiConstants.login,
        {'usuario': cpf, 'senha': senha},
        auth: false, // Login não precisa de token — ainda não temos um
      );
    } on ApiException catch (e) {
      // Transforma o erro 401 genérico em uma mensagem mais amigável
      if (e.statusCode == 401) {
        throw ApiException('CPF ou senha incorretos. Verifique seus dados.');
      }
      rethrow;
    }

    // Extrai os dados retornados pela API após login
    final data   = res['data'] as Map<String, dynamic>?;
    final token  = data?['token']  as String?;
    final role   = (data?['role']  as String?) ?? '';
    final userId = data?['userId'] as String?;

    if (token == null || token.isEmpty) {
      throw ApiException('Token nao retornado pelo servidor.');
    }

    // Bloqueia acesso de administradores pelo app de dono — cada um tem sua área
    if (role != 'Dono') {
      throw ApiException('Use o painel admin para entrar como administrador.');
    }

    // Salva a sessão no armazenamento local para manter o usuário logado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken,   token);
    await prefs.setString(_keyUsuario, (data?['usuario'] as String?) ?? cpf);
    await prefs.setString(_keyRole,    role);
    // O donoId é usado para filtrar pets e consultas do usuário logado
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(_keyDonoId, userId);
    } else {
      await prefs.remove(_keyDonoId);
    }
  }

  /* Remove todos os dados da sessão.
   * Chamado ao pressionar "Sair" na tela de perfil.
   * Após logout, o usuário é redirecionado para a tela de login. */
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUsuario);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyDonoId);
  }

  // Verifica se há um token salvo (indica que o usuário está logado)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken) != null;
  }

  /* Recupera o token JWT salvo.
   * Chamado pelo ApiService para incluir no cabeçalho Authorization de cada requisição. */
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // Recupera o CPF/usuário do dono logado — exibido na tela de perfil
  static Future<String?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsuario);
  }

  // Recupera o papel (role) do usuário — "Dono" para tutores de animais
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  /* Recupera o ID do dono logado.
   * Usado para filtrar consultas e pets: apenas os do dono atual são exibidos. */
  static Future<String?> getDonoId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDonoId);
  }

  // Atalho para verificar se o usuário logado tem a role de Dono
  static Future<bool> isDono() async => (await getRole()) == 'Dono';

  /* Valida o token JWT contra o servidor.
   * Usado na SplashScreen ao abrir o app para verificar se o token ainda é válido.
   * Se o token expirou, o logout é feito automaticamente e retorna false. */
  static Future<bool> validarToken() async {
    try {
      // Chama o endpoint /me — se retornar 200, o token é válido
      await ApiService.get(ApiConstants.me);
      return true;
    } catch (_) {
      // Token inválido ou expirado — limpa os dados locais para forçar novo login
      await logout();
      return false;
    }
  }
}
