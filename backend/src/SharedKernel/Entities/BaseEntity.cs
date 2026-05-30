namespace VetBook.SharedKernel.Entities;

/* Classe base para todas as entidades de domínio do sistema.
 * Fornece ID único (GUID), data de cadastro e data de atualização.
 * Também implementa igualdade por ID em vez de por referência de memória
 * — duas entidades com o mesmo Id são consideradas iguais. */
public abstract class BaseEntity
{
    // Identificador único global — gerado automaticamente no construtor
    public Guid Id { get; protected set; }

    // Data e hora UTC do cadastro — definida uma única vez na criação
    public DateTime DataCadastro { get; protected set; }

    // Data e hora da última atualização — null até a primeira modificação
    public DateTime? DataAtualizacao { get; protected set; }

    protected BaseEntity()
    {
        // Garante que toda entidade nasce com ID único e data de cadastro
        Id = Guid.NewGuid();
        DataCadastro = DateTime.UtcNow;
    }

    // Deve ser chamado pelas entidades filhas ao serem atualizadas
    protected void SetUpdatedAt() => DataAtualizacao = DateTime.UtcNow;

    // Igualdade baseada no Id — entidades do mesmo tipo com mesmo Id são iguais
    public override bool Equals(object? obj)
    {
        if (obj is not BaseEntity other) return false;
        if (ReferenceEquals(this, other)) return true;  // Mesma referência → igual
        if (GetType() != other.GetType()) return false;  // Tipos diferentes → não igual
        return Id == other.Id;
    }

    public override int GetHashCode() => Id.GetHashCode();

    // Operadores == e != para comparação entre entidades
    public static bool operator ==(BaseEntity? left, BaseEntity? right)
        => Equals(left, right);

    public static bool operator !=(BaseEntity? left, BaseEntity? right)
        => !Equals(left, right);
}
