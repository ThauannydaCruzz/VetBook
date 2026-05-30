import 'api_service.dart';
import '../models/consulta_model.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';

/* Serviço responsável por todas as operações de consultas veterinárias.
 * O token JWT do dono logado é usado automaticamente pelo ApiService.
 * Operações administrativas (confirmar, cancelar, finalizar pelo admin)
 * recebem um `customToken` com o token do administrador. */
class ConsultaService {
  /* Lista consultas com filtros combinados e paginação.
   * Todos os parâmetros são opcionais — o backend aplica apenas os informados.
   * Filtros disponíveis:
   *   petId, veterinarioId, donoId — filtrar pelo dono do pet (tela "Consultas")
   *   status — "Agendada", "Confirmada", "Cancelada" ou "Finalizada"
   *   dataInicio/dataFim — intervalo de datas para a agenda do veterinário */
  static Future<PagedResult<ConsultaModel>> listar({
    String? petId,
    String? veterinarioId,
    String? donoId,
    String? status,
    DateTime? dataInicio,
    DateTime? dataFim,
    int page = 1,
    int pageSize = 50,
  }) async {
    // Monta a URL com todos os filtros disponíveis
    var url = '${ApiConstants.consultas}?page=$page&pageSize=$pageSize';
    if (petId         != null) url += '&petId=$petId';
    if (veterinarioId != null) url += '&veterinarioId=$veterinarioId';
    if (donoId        != null) url += '&donoId=$donoId';
    if (status        != null) url += '&status=$status';
    // Datas devem ser enviadas em UTC no formato ISO 8601
    if (dataInicio    != null) url += '&dataInicio=${dataInicio.toUtc().toIso8601String()}';
    if (dataFim       != null) url += '&dataFim=${dataFim.toUtc().toIso8601String()}';
    final res = await ApiService.get(url);
    return PagedResult.fromJson(
      res['data'] as Map<String, dynamic>,
      ConsultaModel.fromJson,
    );
  }

  /* Lista todas as consultas de um pet específico — histórico médico completo.
   * Usa a rota GET /consultas/pet/{petId} que retorna lista sem paginação. */
  static Future<List<ConsultaModel>> listarPorPet(String petId) async {
    final res  = await ApiService.get(ApiConstants.consultasPorPet(petId));
    final data = res['data'] as List<dynamic>;
    return data.map((e) => ConsultaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /* Lista consultas de um veterinário com paginação grande (200).
   * O `customToken` é usado pelo admin na tela de agenda do veterinário.
   * Retorna a lista de items do PagedResult diretamente. */
  static Future<List<ConsultaModel>> listarPorVet(String vetId, {String? customToken}) async {
    // Busca até 200 registros para cobrir o histórico completo do veterinário
    final url  = '${ApiConstants.consultas}?veterinarioId=$vetId&pageSize=200';
    final res  = await ApiService.get(url, customToken: customToken);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final items = data['items'] as List<dynamic>? ?? [];
    return items.map((e) => ConsultaModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /* Agenda uma nova consulta — envia POST /consultas com os dados do agendamento.
   * Retorna a consulta criada com ID e status "Agendada". */
  static Future<ConsultaModel> agendar(CreateConsultaRequest request) async {
    final res = await ApiService.post(ApiConstants.consultas, request.toJson());
    return ConsultaModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  /* Cancela uma consulta — envia PATCH /consultas/{id}/cancelar com o motivo.
   * Tanto o dono quanto o admin podem cancelar.
   * O `customToken` é usado quando o admin cancela pelo painel. */
  static Future<void> cancelar(String id, String motivo, {String? customToken}) async {
    await ApiService.patch(
      ApiConstants.consultaCancelar(id),
      body: {'motivoCancelamento': motivo},
      customToken: customToken,
    );
  }

  /* Confirma uma consulta agendada — muda o status para "Confirmada".
   * Operação realizada pelo admin na agenda do veterinário. */
  static Future<void> confirmar(String id, {String? customToken}) async {
    await ApiService.patch(ApiConstants.consultaConfirmar(id), customToken: customToken);
  }

  /* Finaliza uma consulta realizada — muda o status para "Finalizada".
   * Pode incluir observações do atendimento (laudos, orientações). */
  static Future<void> finalizar(String id, String observacoes, {String? customToken}) async {
    await ApiService.patch(
      ApiConstants.consultaFinalizar(id),
      body: {'observacoes': observacoes},
      customToken: customToken,
    );
  }
}
