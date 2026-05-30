import 'admin_auth_service.dart';
import 'api_service.dart';
import '../models/veterinario_model.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';

/* Serviço responsável pelas operações de veterinários.
 *
 * Dois contextos de uso:
 * - Donos: listam veterinários ATIVOS para escolher no wizard de agendamento
 * - Admin: gerencia todos os veterinários (criar, ativar, inativar, remover) */
class VeterinarioService {
  /* Lista apenas veterinários com ativo=true.
   * Usado pelo dono no passo 2 do wizard de agendamento.
   * Veterinários inativos não aparecem para agendamento. */
  static Future<List<VeterinarioModel>> listarAtivos() async {
    final res  = await ApiService.get(ApiConstants.veterinariosAtivos);
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => VeterinarioModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /* Lista todos os veterinários com paginação — usado no painel admin.
   * O `customToken` com token de admin é necessário para acessar este endpoint. */
  static Future<PagedResult<VeterinarioModel>> listar({
    String? nome,
    int page = 1,
    int pageSize = 50,
    String? customToken,
  }) async {
    var url = '${ApiConstants.veterinarios}?page=$page&pageSize=$pageSize';
    if (nome != null && nome.isNotEmpty) url += '&nome=$nome';
    // Busca o token admin automaticamente se não for passado
    final token = customToken ?? await AdminAuthService.getAdminToken();
    final res = await ApiService.get(url, customToken: token);
    return PagedResult.fromJson(
      res['data'] as Map<String, dynamic>,
      VeterinarioModel.fromJson,
    );
  }

  /* Cria um novo veterinário — operação exclusiva do admin.
   * O veterinário nasce com ativo=true por padrão no backend. */
  static Future<VeterinarioModel> criar(CreateVeterinarioRequest request) async {
    final adminToken = await AdminAuthService.getAdminToken();
    final res = await ApiService.post(
      ApiConstants.veterinarios,
      request.toJson(),
      customToken: adminToken,
    );
    return VeterinarioModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  /* Ativa um veterinário inativo — ele volta a aparecer para agendamento.
   * Operação via PATCH /veterinarios/{id}/ativar. */
  static Future<void> ativar(String id) async {
    final adminToken = await AdminAuthService.getAdminToken();
    await ApiService.patch(ApiConstants.veterinarioAtivar(id), customToken: adminToken);
  }

  /* Inativa um veterinário — ele deixa de aparecer para novos agendamentos.
   * Preferível à remoção para preservar o histórico de consultas. */
  static Future<void> inativar(String id) async {
    final adminToken = await AdminAuthService.getAdminToken();
    await ApiService.patch(ApiConstants.veterinarioInativar(id), customToken: adminToken);
  }

  // Remove permanentemente um veterinário do sistema — use inativar quando possível
  static Future<void> remover(String id) async {
    final adminToken = await AdminAuthService.getAdminToken();
    await ApiService.delete(ApiConstants.veterinarioById(id), customToken: adminToken);
  }
}
