namespace VetBook.VeterinarioContext.Domain.Entities;

/* Entidade de domínio Clinica — representa uma clínica veterinária no sistema.
 * Encapsula todas as regras de negócio relacionadas ao ciclo de vida da clínica.
 * O construtor protegido é necessário para o Entity Framework (materialização). */
public class Clinica
{
    public Guid   Id             { get; private set; }
    public string Nome           { get; private set; } = null!;
    public string Endereco       { get; private set; } = null!;
    public string Telefone       { get; private set; } = null!;
    public string? Email         { get; private set; }
    public bool   Ativo          { get; private set; }
    public DateTime DataCadastro { get; private set; }
    public DateTime? DataAtualizacao { get; private set; }

    // Construtor protegido sem parâmetros — necessário para o EF Core criar instâncias ao ler do banco
    protected Clinica() { }

    /* Factory method estático para criar uma nova clínica.
     * Valida os campos obrigatórios e retorna instância já inicializada.
     * Toda clínica nasce ativa e com a data de cadastro em UTC. */
    public static Clinica Criar(string nome, string endereco, string telefone, string? email)
    {
        if (string.IsNullOrWhiteSpace(nome))     throw new ArgumentException("Nome e obrigatorio.");
        if (string.IsNullOrWhiteSpace(endereco)) throw new ArgumentException("Endereco e obrigatorio.");
        if (string.IsNullOrWhiteSpace(telefone)) throw new ArgumentException("Telefone e obrigatorio.");

        return new Clinica
        {
            Id           = Guid.NewGuid(),
            Nome         = nome.Trim(),
            Endereco     = endereco.Trim(),
            Telefone     = telefone.Trim(),
            Email        = email?.Trim(),  // Email é opcional — pode ser null
            Ativo        = true,           // Sempre nasce ativa
            DataCadastro = DateTime.UtcNow
        };
    }

    // Atualiza os dados da clínica e registra a data de atualização
    public void Atualizar(string nome, string endereco, string telefone, string? email)
    {
        Nome           = nome.Trim();
        Endereco       = endereco.Trim();
        Telefone       = telefone.Trim();
        Email          = email?.Trim();
        DataAtualizacao = DateTime.UtcNow;
    }

    // Liga/desliga a clínica — afeta disponibilidade no agendamento
    public void Ativar()   { Ativo = true;  DataAtualizacao = DateTime.UtcNow; }
    public void Inativar() { Ativo = false; DataAtualizacao = DateTime.UtcNow; }
}
