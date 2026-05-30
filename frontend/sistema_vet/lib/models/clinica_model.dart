/* Model que representa uma clínica veterinária no app Flutter.
 * Usado tanto na tela de agendamento (para mostrar onde o vet atende)
 * quanto no painel admin (para gerenciar clínicas). */
class ClinicaModel {
  final String  id;
  final String  nome;
  final String  endereco;
  final String  telefone;
  final String? email;      // E-mail de contato (opcional)
  final bool    ativo;      // Se false, não aparece na seleção de agendamento
  final DateTime dataCadastro;

  const ClinicaModel({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.telefone,
    this.email,
    required this.ativo,
    required this.dataCadastro,
  });

  // Converte o JSON da API para ClinicaModel
  factory ClinicaModel.fromJson(Map<String, dynamic> json) => ClinicaModel(
        id:           json['id']           as String,
        nome:         json['nome']         as String,
        endereco:     json['endereco']     as String,
        telefone:     json['telefone']     as String,
        email:        json['email']        as String?,
        ativo:        json['ativo']        as bool? ?? true,
        dataCadastro: DateTime.tryParse(json['dataCadastro'] as String? ?? '') ??
            DateTime.now(),
      );

  // Gera as iniciais do nome da clínica para exibir em avatares (ex: "Pet Care" → "PC")
  String get iniciais {
    final parts = nome.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nome.substring(0, nome.length >= 2 ? 2 : 1).toUpperCase();
  }
}

// DTO usado para criar uma nova clínica — enviado para a API no POST /clinicas
class CreateClinicaRequest {
  final String  nome;
  final String  endereco;
  final String  telefone;
  final String? email;

  const CreateClinicaRequest({
    required this.nome,
    required this.endereco,
    required this.telefone,
    this.email,
  });

  // Converte para Map para enviar como JSON
  Map<String, dynamic> toJson() => {
    'nome':     nome,
    'endereco': endereco,
    'telefone': telefone,
    if (email != null) 'email': email,
  };
}
