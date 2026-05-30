import 'api_service.dart';
import '../models/pet_model.dart';
import '../models/api_response.dart';
import '../utils/constants.dart';

/* Serviço responsável pelo gerenciamento de pets no app.
 * O token do dono logado é usado automaticamente em todas as chamadas,
 * pois estas operações fazem parte da área do dono autenticado. */
class PetService {
  /* Lista pets com filtros opcionais e paginação.
   * Usado pelo admin (listar todos os pets) e pelo dono (filtrar por donoId).
   * Para a tela "Meus Pets" do dono, prefira `listarPorDono()` que retorna lista completa. */
  static Future<PagedResult<PetModel>> listar({
    String? nome,
    String? donoId,
    int page = 1,
    int pageSize = 20,
  }) async {
    var url = '${ApiConstants.pets}?page=$page&pageSize=$pageSize';
    if (nome   != null && nome.isNotEmpty) url += '&nome=$nome';
    if (donoId != null) url += '&donoId=$donoId';
    final res = await ApiService.get(url);
    return PagedResult.fromJson(
      res['data'] as Map<String, dynamic>,
      PetModel.fromJson,
    );
  }

  /* Lista todos os pets de um dono específico sem paginação.
   * Usa a rota especial GET /pets/dono/{donoId} — retorna uma lista simples.
   * Usado na tela "Meus Pets" e no wizard de agendamento (para selecionar o pet). */
  static Future<List<PetModel>> listarPorDono(String donoId) async {
    final res  = await ApiService.get(ApiConstants.petsByDono(donoId));
    final data = res['data'] as List<dynamic>;
    return data.map((e) => PetModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Busca um pet específico pelo ID — usado para exibir os detalhes do animal
  static Future<PetModel> obterPorId(String id) async {
    final res = await ApiService.get(ApiConstants.petById(id));
    return PetModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  /* Cadastra um novo pet — envia os dados para POST /pets.
   * O donoId deve ser preenchido com o ID do dono logado (obtido via AuthService.getDonoId()). */
  static Future<PetModel> criar(CreatePetRequest request) async {
    final res = await ApiService.post(ApiConstants.pets, request.toJson());
    return PetModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  /* Remove um pet pelo ID.
   * A API bloqueia a remoção se o pet tiver consultas futuras agendadas ou confirmadas. */
  static Future<void> remover(String id) async {
    await ApiService.delete(ApiConstants.petById(id));
  }
}
