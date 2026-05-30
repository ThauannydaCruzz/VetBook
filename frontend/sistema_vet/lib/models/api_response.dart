/* Modelos Dart que espelham os tipos genéricos da API.
 *
 * ApiResponse<T> — envelope padrão de toda resposta da API:
 *   { "success": true, "message": "...", "data": {...}, "errors": [...] }
 *
 * PagedResult<T> — envelope de listas paginadas:
 *   { "items": [...], "totalItems": 50, "page": 1, "pageSize": 10, ... }
 *
 * Ambos usam factory constructors para desserializar o JSON recebido do backend. */

/* Envelope genérico de resposta — usado em todas as chamadas da API.
 * O campo `data` é desserializado usando a função `fromData` passada como parâmetro,
 * o que permite reutilizar este modelo para qualquer tipo de dado (T). */
class ApiResponse<T> {
  final bool success;       // true = operação bem-sucedida
  final String message;     // Mensagem descritiva (ex: "Consulta agendada com sucesso")
  final T? data;            // Dados retornados (pode ser null em operações como DELETE)
  final List<String>? errors; // Lista de erros de validação (ex: ["CPF inválido"])

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  /* Desserializa o JSON para ApiResponse<T>.
   * O parâmetro `fromData` é uma função que converte o campo "data" do JSON
   * para o tipo T desejado (ex: DonoModel.fromJson, ConsultaModel.fromJson). */
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      // Converte o campo "data" somente se ele não for nulo e fromData for fornecido
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : null,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

/* Envelope de resposta paginada — usado nas listagens com muitos itens.
 * Contém a página atual de itens e metadados de paginação. */
class PagedResult<T> {
  final List<T> items;        // Itens da página atual
  final int totalItems;       // Total de registros no banco (todas as páginas)
  final int page;             // Página atual (começa em 1)
  final int pageSize;         // Quantidade de itens por página
  final int totalPages;       // Total de páginas disponíveis
  final bool hasPreviousPage; // Há uma página anterior?
  final bool hasNextPage;     // Há uma próxima página?

  PagedResult({
    required this.items,
    required this.totalItems,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  /* Desserializa o JSON para PagedResult<T>.
   * O parâmetro `fromItem` converte cada elemento do array "items" para o tipo T.
   * Exemplo de uso: PagedResult.fromJson(json, DonoModel.fromJson) */
  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    return PagedResult<T>(
      // Converte a lista de Maps em uma lista tipada usando fromItem
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      totalItems:      json['totalItems']      as int? ?? 0,
      page:            json['page']            as int? ?? 1,
      pageSize:        json['pageSize']        as int? ?? 10,
      totalPages:      json['totalPages']      as int? ?? 0,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      hasNextPage:     json['hasNextPage']     as bool? ?? false,
    );
  }
}
