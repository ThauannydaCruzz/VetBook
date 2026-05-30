import 'admin_auth_service.dart';
import 'api_service.dart';
import '../models/clinica_model.dart';
import '../utils/constants.dart';

/* Serviço responsável pelas operações de clínicas veterinárias.
 *
 * Dois contextos de uso:
 * - Donos: listam clínicas ATIVAS no passo 1 do wizard de agendamento
 * - Admin: gerencia todas as clínicas (criar, remover) com token de admin */
class ClinicaService {
  /* Lista clínicas com ativo=true — exibidas no wizard de agendamento.
   * Usa o token do dono logado automaticamente (ApiService injeta o token). */
  static Future<List<ClinicaModel>> listarAtivas() async {
    final res  = await ApiService.get(ApiConstants.clinicasAtivas);
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => ClinicaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /* Lista todas as clínicas (ativas e inativas) — usado no painel admin.
   * A resposta pode ser paginada (Map com "items") ou uma lista simples —
   * o código trata ambos os casos para compatibilidade. */
  static Future<List<ClinicaModel>> listarTodas() async {
    final adminToken = await AdminAuthService.getAdminToken();
    final res  = await ApiService.get(ApiConstants.clinicas, customToken: adminToken);
    final data = res['data'];
    // Se "data" for um Map paginado, extrai "items"; caso contrário usa a lista direta
    final items = data is Map ? (data['items'] as List? ?? []) : (data as List? ?? []);
    return items.map((e) => ClinicaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /* Cria uma nova clínica — operação exclusiva do admin.
   * A clínica nasce ativa por padrão no backend. */
  static Future<ClinicaModel> criar(CreateClinicaRequest request) async {
    final adminToken = await AdminAuthService.getAdminToken();
    final res = await ApiService.post(
      ApiConstants.clinicas,
      request.toJson(),
      customToken: adminToken,
    );
    return ClinicaModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  /* Remove uma clínica pelo ID — operação exclusiva do admin.
   * Quando uma clínica é removida, os veterinários vinculados perdem
   * o link (clinicaId fica null) mas não são removidos. */
  static Future<void> remover(String id) async {
    final adminToken = await AdminAuthService.getAdminToken();
    await ApiService.delete(
      ApiConstants.clinicaById(id),
      customToken: adminToken,
    );
  }
}
