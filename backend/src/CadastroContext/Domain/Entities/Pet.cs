using VetBook.SharedKernel.Entities;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.CadastroContext.Domain.Entities;

// Enum que representa o sexo do animal
public enum SexoPet { Macho, Femea }

/* Entidade de domínio que representa um Pet (animal de estimação).
 * Todo pet pertence a um Dono — a relação é feita pelo DonoId.
 * Assim como Dono, segue o padrão DDD com setters privados e método fábrica. */
public class Pet : BaseEntity
{
    // Nome do animal (ex: "Rex", "Mimi")
    public string Nome { get; private set; } = default!;

    // Espécie do animal (ex: "Cachorro", "Gato", "Coelho")
    public string Especie { get; private set; } = default!;

    // Raça do animal (ex: "Labrador", "Siamês")
    public string Raca { get; private set; } = default!;

    // Idade em anos
    public int Idade { get; private set; }

    // Peso em quilogramas
    public decimal Peso { get; private set; }

    // Sexo do animal: Macho (0) ou Fêmea (1)
    public SexoPet Sexo { get; private set; }

    // Campo opcional para informações adicionais (vacinas, alergias, etc.)
    public string? Observacoes { get; private set; }

    // Chave estrangeira — ID do dono ao qual este pet pertence
    public Guid DonoId { get; private set; }

    // Propriedade de navegação do Entity Framework — carregada com Include()
    public Dono? Dono { get; private set; }

    // Construtor sem parâmetros exigido pelo Entity Framework
    protected Pet() { }

    // Construtor privado — chamado apenas pelo método fábrica Criar()
    private Pet(string nome, string especie, string raca, int idade,
                decimal peso, SexoPet sexo, string? observacoes, Guid donoId)
    {
        Nome = nome;
        Especie = especie;
        Raca = raca;
        Idade = idade;
        Peso = peso;
        Sexo = sexo;
        Observacoes = observacoes;
        DonoId = donoId;
    }

    // Método fábrica — cria um Pet validado
    public static Pet Criar(string nome, string especie, string raca, int idade,
                            decimal peso, SexoPet sexo, string? observacoes, Guid donoId)
    {
        Validar(nome, especie, raca, idade, peso, donoId);
        return new Pet(nome, especie, raca, idade, peso, sexo, observacoes, donoId);
    }

    // Atualiza os dados do pet — o DonoId não pode ser alterado (pet não muda de dono)
    public void Atualizar(string nome, string especie, string raca, int idade,
                          decimal peso, SexoPet sexo, string? observacoes)
    {
        Validar(nome, especie, raca, idade, peso, DonoId);
        Nome = nome;
        Especie = especie;
        Raca = raca;
        Idade = idade;
        Peso = peso;
        Sexo = sexo;
        Observacoes = observacoes;
        SetUpdatedAt();
    }

    // Validações aplicadas tanto na criação quanto na atualização
    private static void Validar(string nome, string especie, string raca,
                                 int idade, decimal peso, Guid donoId)
    {
        if (string.IsNullOrWhiteSpace(nome))
            throw new DomainException("Nome do pet e obrigatorio.");
        if (nome.Length > 100)
            throw new DomainException("Nome do pet deve ter no maximo 100 caracteres.");
        if (string.IsNullOrWhiteSpace(especie))
            throw new DomainException("Especie e obrigatoria.");
        if (string.IsNullOrWhiteSpace(raca))
            throw new DomainException("Raca e obrigatoria.");
        if (idade < 0 || idade > 50)
            throw new DomainException("Idade invalida para o pet.");
        if (peso <= 0)
            throw new DomainException("Peso deve ser maior que zero.");
        if (donoId == Guid.Empty)
            throw new DomainException("Dono e obrigatorio para cadastro de pet.");
    }
}
