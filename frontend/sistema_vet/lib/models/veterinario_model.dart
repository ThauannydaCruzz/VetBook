/* Model que representa um veterinário no app Flutter.
 * Contém os dados exibidos nas telas de agendamento e no painel admin. */
class VeterinarioModel {
  final String  id;
  final String  nome;
  final String  crmv;            // Registro profissional (ex: "SP-12345")
  final String  especialidade;
  final String  email;
  final String  telefone;
  final bool    ativo;           // Se false, não aparece para agendamento
  final String? clinicaId;      // Pode ser nulo se o vet for autônomo
  final String? clinicaNome;    // Nome da clínica para exibição
  final String  dataCadastro;

  VeterinarioModel({
    required this.id,
    required this.nome,
    required this.crmv,
    required this.especialidade,
    required this.email,
    required this.telefone,
    required this.ativo,
    this.clinicaId,
    this.clinicaNome,
    required this.dataCadastro,
  });

  // Converte o JSON da API para VeterinarioModel
  factory VeterinarioModel.fromJson(Map<String, dynamic> json) => VeterinarioModel(
        id:            json['id']            as String,
        nome:          json['nome']          as String,
        crmv:          json['crmv']          as String,
        especialidade: json['especialidade'] as String,
        email:         json['email']         as String,
        telefone:      json['telefone']      as String,
        ativo:         json['ativo']         as bool,
        clinicaId:     json['clinicaId']     as String?,
        clinicaNome:   json['clinicaNome']   as String?,
        dataCadastro:  json['dataCadastro']  as String,
      );

  // Gera as iniciais do nome para exibir em avatares (ex: "João Silva" → "JS")
  String get iniciais {
    final parts = nome.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

// DTO usado para criar um novo veterinário — enviado para a API no POST /veterinarios
class CreateVeterinarioRequest {
  final String  nome;
  final String  crmv;
  final String  especialidade;
  final String  email;
  final String  telefone;
  final String? clinicaId;   // Opcional — veterinário pode não estar vinculado a uma clínica

  CreateVeterinarioRequest({
    required this.nome,
    required this.crmv,
    required this.especialidade,
    required this.email,
    required this.telefone,
    this.clinicaId,
  });

  // Converte para Map para enviar como JSON
  Map<String, dynamic> toJson() => {
    'nome':         nome,
    'crmv':         crmv,
    'especialidade': especialidade,
    'email':        email,
    'telefone':     telefone,
    if (clinicaId != null) 'clinicaId': clinicaId, // Inclui clinicaId apenas se não for nulo
  };
}
