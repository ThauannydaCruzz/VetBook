/* Model que representa um pet (animal) no app Flutter.
 * Contém os dados do animal e do dono ao qual pertence.
 * O getter emojiEspecie retorna um emoji baseado na espécie do animal — usado na UI. */
class PetModel {
  final String id;
  final String nome;
  final String especie;       // Ex: "Cachorro", "Gato", "Coelho"
  final String raca;
  final int idade;
  final double peso;          // Em quilogramas
  final String sexo;          // "Macho" ou "Femea"
  final String? observacoes;  // Informações opcionais (alergias, vacinas, etc.)
  final String donoId;        // ID do tutor responsável
  final String dataCadastro;

  PetModel({
    required this.id,
    required this.nome,
    required this.especie,
    required this.raca,
    required this.idade,
    required this.peso,
    required this.sexo,
    this.observacoes,
    required this.donoId,
    required this.dataCadastro,
  });

  // Converte o JSON da API para PetModel
  factory PetModel.fromJson(Map<String, dynamic> json) => PetModel(
        id: json['id'] as String,
        nome: json['nome'] as String,
        especie: json['especie'] as String,
        raca: json['raca'] as String,
        idade: json['idade'] as int,
        peso: (json['peso'] as num).toDouble(),
        sexo: json['sexo'] as String,
        observacoes: json['observacoes'] as String?,
        donoId: json['donoId'] as String,
        dataCadastro: json['dataCadastro'] as String,
      );

  // Retorna um emoji representando a espécie do pet — exibido nos cards da lista de pets
  String get emojiEspecie {
    final e = especie.toLowerCase();
    if (e.contains('cao') || e.contains('cachorro')) return '🐶';
    if (e.contains('gat')) return '🐱';
    if (e.contains('coelh')) return '🐰';
    if (e.contains('passaro') || e.contains('ave')) return '🐦';
    return '🐾'; // Emoji genérico de pata para outras espécies
  }
}

// DTO usado para cadastrar um novo pet — enviado para a API no POST /pets
class CreatePetRequest {
  final String nome;
  final String especie;
  final String raca;
  final int idade;
  final double peso;
  final int sexo;          // 0 = Macho, 1 = Fêmea (enum numérico esperado pela API)
  final String? observacoes;
  final String donoId;

  CreatePetRequest({
    required this.nome,
    required this.especie,
    required this.raca,
    required this.idade,
    required this.peso,
    required this.sexo,
    this.observacoes,
    required this.donoId,
  });

  // Converte para Map para enviar como JSON
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'especie': especie,
        'raca': raca,
        'idade': idade,
        'peso': peso,
        'sexo': sexo,
        'observacoes': observacoes,
        'donoId': donoId,
      };
}
