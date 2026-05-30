import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../utils/constants.dart';

/* Serviço de autenticação específico para administradores do sistema.
 * Separado do AuthService para não misturar tokens de dono e admin —
 * ambos podem estar logados simultaneamente (token do dono no SharedPreferences
 * e token do admin em chave diferente).
 *
 * O admin pode:
 * - Criar, ativar e inativar veterinários
 * - Criar e remover clínicas
 * - Ver todos os donos cadastrados
 * - Gerenciar a agenda de consultas dos veterinários */
class AdminAuthService {
  // Chaves distintas das do AuthService para evitar conflito de tokens
  static const _keyAdminToken = 'admin_jwt_token';
  static const _keyAdminUser  = 'admin_usuario';

  /* Faz login como administrador.
   * Chama a mesma rota /api/auth/login, mas valida que o role retornado é "Admin".
   * Lança ApiException se as credenciais forem inválidas ou o usuário não for admin. */
  static Future<void> loginAdmin(String usuario, String senha) async {
    final res = await ApiService.post(
      ApiConstants.login,
      {'usuario': usuario, 'senha': senha},
      auth: false, // Login sem token — ainda não temos um
    );

    final data  = res['data'] as Map<String, dynamic>?;
    final token = data?['token'] as String?;
    final role  = data?['role']  as String?;

    if (token == null) throw ApiException('Token nao retornado.');

    // Garante que apenas administradores acessem o painel admin
    if (role != 'Admin') {
      throw ApiException('Acesso negado. Use credenciais de administrador.');
    }

    // Salva o token e o nome do admin separadamente dos dados do dono
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAdminToken, token);
    await prefs.setString(_keyAdminUser,  data?['usuario'] as String? ?? usuario);
  }

  /* Remove os dados de sessão do administrador.
   * Chamado ao clicar em "Sair" no painel admin.
   * O dono pode continuar logado no app — as sessões são independentes. */
  static Future<void> logoutAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAdminToken);
    await prefs.remove(_keyAdminUser);
  }

  /* Verifica se o admin está logado E se o token ainda é válido no servidor.
   * Ao abrir a aba Admin, esta verificação garante que o token não expirou.
   * Se expirou, os dados locais são limpos e o login é solicitado novamente. */
  static Future<bool> isAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyAdminToken);

    // Sem token salvo = não está logado
    if (token == null) return false;

    // Valida o token no servidor — o endpoint /me retorna 401 se expirou
    try {
      await ApiService.get(ApiConstants.me, customToken: token);
      return true;
    } catch (_) {
      // Token expirado ou inválido — limpa os dados e força novo login
      await prefs.remove(_keyAdminToken);
      await prefs.remove(_keyAdminUser);
      return false;
    }
  }

  /* Recupera o token do admin — passado como `customToken` nas requisições
   * que precisam de autorização de administrador. */
  static Future<String?> getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdminToken);
  }

  // Recupera o nome/usuário do admin logado — exibido no cabeçalho do painel
  static Future<String?> getAdminUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAdminUser);
  }
}
