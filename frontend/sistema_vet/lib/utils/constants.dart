import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/* Constantes da API — centraliza todas as URLs usadas no app.
 * A URL base é detectada automaticamente de acordo com a plataforma:
 * - Web (Chrome): usa localhost diretamente
 * - Android Emulator: usa 10.0.2.2 (endereço especial que aponta para o host do emulador)
 * - Outras plataformas (Windows, iOS, macOS): usa localhost
 *
 * Os getters e métodos estáticos constroem as URLs completas de cada endpoint,
 * evitando repetição de strings espalhadas pelo código. */
class ApiConstants {
  // URL base detectada automaticamente pela plataforma em execução
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5000';
    return 'http://localhost:5000';
  }

  // Endpoints de autenticação
  static String get login => '$baseUrl/api/auth/login';
  static String get me    => '$baseUrl/api/auth/me';   // Valida o token atual no servidor

  // Endpoints de donos (tutores)
  static String get donos        => '$baseUrl/api/donos';
  static String donoById(String id) => '$baseUrl/api/donos/$id';

  // Endpoints de pets
  static String get pets              => '$baseUrl/api/pets';
  static String petById(String id)    => '$baseUrl/api/pets/$id';
  // Rota especial que retorna os pets de um dono sem paginação
  static String petsByDono(String donoId) => '$baseUrl/api/pets/dono/$donoId';

  // Endpoints de veterinários
  static String get veterinarios         => '$baseUrl/api/veterinarios';
  // Rota que retorna apenas veterinários com ativo=true (para agendamento)
  static String get veterinariosAtivos   => '$baseUrl/api/veterinarios/ativos';
  static String veterinarioById(String id) => '$baseUrl/api/veterinarios/$id';
  static String veterinarioAtivar(String id)   => '$baseUrl/api/veterinarios/$id/ativar';
  static String veterinarioInativar(String id) => '$baseUrl/api/veterinarios/$id/inativar';

  // Endpoints de clínicas veterinárias
  static String get clinicas       => '$baseUrl/api/clinicas';
  // Rota que retorna apenas clínicas ativas (para o wizard de agendamento)
  static String get clinicasAtivas => '$baseUrl/api/clinicas/ativas';
  static String clinicaById(String id) => '$baseUrl/api/clinicas/$id';

  // Endpoints de consultas — cobrem todo o ciclo de vida do agendamento
  static String get consultas              => '$baseUrl/api/consultas';
  static String consultaById(String id)   => '$baseUrl/api/consultas/$id';
  static String consultaConfirmar(String id) => '$baseUrl/api/consultas/$id/confirmar';
  static String consultaCancelar(String id)  => '$baseUrl/api/consultas/$id/cancelar';
  static String consultaFinalizar(String id) => '$baseUrl/api/consultas/$id/finalizar';
  // Rota para histórico médico do pet
  static String consultasPorPet(String petId) => '$baseUrl/api/consultas/pet/$petId';
  // Rota para agenda do veterinário
  static String consultasPorVet(String vetId) => '$baseUrl/api/consultas/veterinario/$vetId';
}
