/* Model que representa uma consulta veterinária no app Flutter.
 * O método fromJson() converte o JSON recebido da API para um objeto Dart.
 * Os getters auxiliares (isPendente, tituloPet, etc.) facilitam o uso nas telas. */
class ConsultaModel {
  final String  id;
  final String  petId;
  final String? nomePet;           // Pode ser nulo se a API não retornar o nome
  final String  veterinarioId;
  final String? nomeVeterinario;   // Pode ser nulo se a API não retornar o nome
  final DateTime dataConsulta;
  final String  motivoConsulta;
  final String  statusConsulta;    // "Agendada", "Confirmada", "Finalizada" ou "Cancelada"
  final String? observacoes;
  final DateTime dataCadastro;

  ConsultaModel({
    required this.id,
    required this.petId,
    this.nomePet,
    required this.veterinarioId,
    this.nomeVeterinario,
    required this.dataConsulta,
    required this.motivoConsulta,
    required this.statusConsulta,
    this.observacoes,
    required this.dataCadastro,
  });

  // Converte o JSON da API para o objeto ConsultaModel.
  // Trata campos opcionais com valores padrão para evitar erros.
  factory ConsultaModel.fromJson(Map<String, dynamic> json) => ConsultaModel(
        id:               json['id']               as String,
        petId:            json['petId']            as String,
        nomePet:          json['nomePet']          as String?,
        veterinarioId:    json['veterinarioId']    as String,
        nomeVeterinario:  json['nomeVeterinario']  as String?,
        dataConsulta:     DateTime.parse(json['dataConsulta'] as String),
        motivoConsulta:   json['motivoConsulta']   as String? ?? '',
        statusConsulta:   json['statusConsulta']   as String? ?? 'Agendada',
        observacoes:      json['observacoes']      as String?,
        // Tenta 'dataCadastro' e depois 'dataCriacao' como fallback
        dataCadastro:     DateTime.tryParse(
                            json['dataCadastro'] as String? ??
                            json['dataCriacao']  as String? ?? '') ??
                          DateTime.now(),
      );

  // Verdadeiro se a consulta ainda está em andamento (pode ser cancelada ou reagendada)
  bool get isPendente  => statusConsulta == 'Agendada' || statusConsulta == 'Confirmada';

  // Verdadeiro se a consulta foi cancelada (estado terminal)
  bool get isCancelada => statusConsulta == 'Cancelada';

  // Verdadeiro se a consulta foi realizada (estado terminal)
  bool get isFinalizada => statusConsulta == 'Finalizada';

  // Retorna o nome do pet ou um texto padrão se não disponível
  String get tituloPet => nomePet ?? 'Pet';

  // Retorna o nome do veterinário ou um texto padrão se não disponível
  String get tituloVet => nomeVeterinario ?? 'Veterinario';
}

// DTO usado para criar um novo agendamento — enviado para a API no POST /consultas
class CreateConsultaRequest {
  final String   petId;
  final String   veterinarioId;
  final DateTime dataConsulta;
  final String   motivoConsulta;
  final String?  observacoes;

  CreateConsultaRequest({
    required this.petId,
    required this.veterinarioId,
    required this.dataConsulta,
    required this.motivoConsulta,
    this.observacoes,
  });

  // Converte para Map para enviar como JSON na requisição
  Map<String, dynamic> toJson() => {
    'petId':          petId,
    'veterinarioId':  veterinarioId,
    'dataConsulta':   dataConsulta.toUtc().toIso8601String(), // API espera UTC
    'motivoConsulta': motivoConsulta,
    'observacoes':    observacoes,
  };
}
