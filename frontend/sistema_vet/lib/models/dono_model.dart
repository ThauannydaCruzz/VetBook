/* Model que representa o dono/tutor de animais no app Flutter.
 * DonoModel é usado para exibir dados nas telas de perfil e no painel admin.
 * CreateDonoRequest é o DTO enviado para a API ao criar uma nova conta. */

/* Modelo de leitura — mapeado a partir do JSON retornado pela API. */
class DonoModel {
  final String id;           // GUID gerado pelo backend
  final String nome;
  final String cpf;          // CPF formatado (ex: "123.456.789-09")
  final String email;
  final String telefone;
  final String endereco;
  final String dataCadastro; // Data de criação da conta (ISO 8601)

  DonoModel({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.endereco,
    required this.dataCadastro,
  });

  // Converte o JSON da API para DonoModel — usado em PagedResult.fromJson
  factory DonoModel.fromJson(Map<String, dynamic> json) => DonoModel(
        id:           json['id']           as String,
        nome:         json['nome']         as String,
        cpf:          json['cpf']          as String,
        email:        json['email']        as String,
        telefone:     json['telefone']     as String,
        endereco:     json['endereco']     as String,
        dataCadastro: json['dataCadastro'] as String,
      );
}

/* DTO de criação — enviado no corpo do POST /api/donos durante o cadastro.
 * Inclui a senha em texto puro — o backend faz o hash antes de salvar. */
class CreateDonoRequest {
  final String nome;
  final String cpf;      // Sem formatação (apenas dígitos) ou com pontuação — backend valida
  final String email;
  final String telefone;
  final String endereco;
  final String senha;    // Senha em texto puro — será hasheada no backend

  CreateDonoRequest({
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.endereco,
    required this.senha,
  });

  // Converte para Map para serializar como JSON no corpo da requisição
  Map<String, dynamic> toJson() => {
        'nome':     nome,
        'cpf':      cpf,
        'email':    email,
        'telefone': telefone,
        'endereco': endereco,
        'senha':    senha,
      };
}
