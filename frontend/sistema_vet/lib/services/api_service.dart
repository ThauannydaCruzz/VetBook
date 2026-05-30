import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/* Exceção personalizada para erros de API — carrega a mensagem e o status HTTP.
 * Lançada pelo ApiService quando a resposta indica falha (status >= 300).
 * Os serviços (DonoService, PetService, etc.) capturam ApiException e exibem
 * a mensagem ao usuário. */
class ApiException implements Exception {
  final String message;
  final int? statusCode; // Código HTTP (ex: 400, 401, 404, 500)
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/* Serviço genérico de comunicação com a API.
 * Centraliza todas as chamadas HTTP do app (GET, POST, PUT, PATCH, DELETE).
 * Cada método adiciona automaticamente o token JWT no cabeçalho Authorization.
 *
 * Por que usar métodos estáticos?
 * Os serviços do app (DonoService, PetService, etc.) não precisam de instância
 * — basta chamar ApiService.get(), ApiService.post(), etc. diretamente. */
class ApiService {
  /* Faz uma requisição GET e retorna o corpo JSON como Map.
   * Parâmetros:
   *   url         — URL completa do endpoint
   *   auth        — se true, inclui token JWT no cabeçalho
   *   customToken — token alternativo (ex: token admin em vez do token do dono) */
  static Future<Map<String, dynamic>> get(
    String url, {
    bool auth = true,
    String? customToken,
  }) async {
    final headers = await _headers(auth: auth, customToken: customToken);
    final response = await http.get(Uri.parse(url), headers: headers);
    return _parse(response);
  }

  /* Faz uma requisição POST com corpo JSON e retorna a resposta.
   * Usado para criar recursos (ex: POST /donos, POST /consultas). */
  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    bool auth = true,
    String? customToken,
  }) async {
    final headers = await _headers(auth: auth, customToken: customToken);
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  /* Faz uma requisição PUT (substituição completa de um recurso).
   * Usado para atualizar dados como o perfil do dono. */
  static Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body, {
    bool auth = true,
    String? customToken,
  }) async {
    final headers = await _headers(auth: auth, customToken: customToken);
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  /* Faz uma requisição PATCH (atualização parcial).
   * Usado para ações específicas: confirmar, cancelar ou finalizar uma consulta.
   * O parâmetro `body` é opcional — algumas operações PATCH não precisam de corpo. */
  static Future<Map<String, dynamic>> patch(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
    String? customToken,
  }) async {
    final headers = await _headers(auth: auth, customToken: customToken);
    final response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse(response);
  }

  /* Faz uma requisição DELETE para remover um recurso pelo ID.
   * Usado para remover pets, donos, veterinários e clínicas. */
  static Future<Map<String, dynamic>> delete(
    String url, {
    bool auth = true,
    String? customToken,
  }) async {
    final headers = await _headers(auth: auth, customToken: customToken);
    final response = await http.delete(Uri.parse(url), headers: headers);
    return _parse(response);
  }

  /* Monta o cabeçalho HTTP.
   * Sempre inclui Content-Type e Accept como JSON.
   * Se `auth` for true, adiciona o token JWT no cabeçalho Authorization.
   * O `customToken` tem prioridade sobre o token do AuthService
   * (usado em requisições admin que precisam de token diferente). */
  static Future<Map<String, String>> _headers({
    bool auth = true,
    String? customToken,
  }) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept':       'application/json',
    };
    if (auth) {
      // Token personalizado (ex: admin) tem prioridade sobre o token salvo do dono
      final token = customToken ?? await AuthService.getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  /* Interpreta a resposta HTTP — converte o JSON e trata erros.
   * Se o status for 2xx (200-299), retorna o Map com os dados.
   * Se for 4xx ou 5xx, lança ApiException com a mensagem apropriada. */
  static Map<String, dynamic> _parse(http.Response response) {
    Map<String, dynamic> body;
    try {
      // Tenta desserializar o corpo como JSON
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // Resposta não é JSON válido (ex: erro de rede ou proxy)
      throw ApiException('Resposta invalida do servidor.',
          statusCode: response.statusCode);
    }

    // Resposta bem-sucedida (200-299) — retorna o corpo para o chamador
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Tenta extrair a mensagem de erro do corpo da resposta
    final msg = body['message'] as String? ??
        body['title'] as String? ??
        'Erro ${response.statusCode}';

    if (response.statusCode == 401) {
      // 401 com mensagem específica = credenciais inválidas (ex: login com senha errada)
      // 401 sem mensagem = token expirado ou ausente
      final bodyMsg = body['message'] as String?;
      final exMsg = (bodyMsg != null && bodyMsg.isNotEmpty)
          ? bodyMsg
          : 'Sessao expirada. Faca login novamente.';
      throw ApiException(exMsg, statusCode: 401);
    }
    if (response.statusCode == 403) {
      throw ApiException('Acesso nao autorizado.', statusCode: 403);
    }
    // Outros erros (400 Bad Request, 404 Not Found, 500 Internal Server Error, etc.)
    throw ApiException(msg, statusCode: response.statusCode);
  }
}
