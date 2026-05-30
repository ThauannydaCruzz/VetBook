import 'admin_auth_service.dart';
import 'api_service.dart';
import '../models/dono_model.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';

/* Serviço responsável pelas operações de donos/tutores.
 * As operações de leitura e remoção usam token admin (acesso restrito ao painel).
 * A criação de dono (cadastro) não requer token — qualquer pessoa pode se cadastrar. */
class DonoService {
  /* Lista donos com paginação e filtro opcional por nome.
   * Uso exclusivo do painel admin — usa token de administrador.
   * O `customToken` permite passar um token já obtido para evitar nova chamada async. */
  static Future<PagedResult<DonoModel>> listar({
    String? nome,
    int page = 1,
    int pageSize = 50,
    String? customToken,
  }) async {
    // Monta a URL com os parâmetros de paginação e filtro
    var url = '${ApiConstants.donos}?page=$page&pageSize=$pageSize';
    if (nome != null && nome.isNotEmpty) url += '&nome=$nome';
    // Usa token personalizado ou busca o token admin automaticamente
    final token = customToken ?? await AdminAuthService.getAdminToken();
    final res = await ApiService.get(url, customToken: token);
    return PagedResult.fromJson(
      res['data'] as Map<String, dynamic>,
      DonoModel.fromJson,
    );
  }

  /* Busca um dono pelo ID.
   * Usa o token do dono logado — cada dono pode ver seus próprios dados. */
  static Future<DonoModel> obterPorId(String id) async {
    final res = await ApiService.get(ApiConstants.donoById(id));
    return DonoModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  /* Cria um novo dono no sistema (cadastro público).
   * auth=false indica que este endpoint não requer token JWT —
   * qualquer pessoa pode criar uma conta sem estar autenticada. */
  static Future<DonoModel> criar(CreateDonoRequest request) async {
    final res = await ApiService.post(ApiConstants.donos, request.toJson(), auth: false);
    return DonoModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  /* Remove um dono pelo ID — operação exclusiva do painel admin.
   * A API bloqueia a remoção se o dono tiver pets cadastrados. */
  static Future<void> remover(String id) async {
    final adminToken = await AdminAuthService.getAdminToken();
    await ApiService.delete(ApiConstants.donoById(id), customToken: adminToken);
  }
}
