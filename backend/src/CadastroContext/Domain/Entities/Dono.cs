using VetBook.SharedKernel.Entities;
using VetBook.SharedKernel.Exceptions;
using VetBook.SharedKernel.ValueObjects;

namespace VetBook.CadastroContext.Domain.Entities;

/* Entidade de domínio que representa um Dono (tutor de animais).
 * Segue o padrão DDD: os setters são privados, e toda mudança de estado
 * passa pelos métodos da entidade, que validam as regras de negócio.
 * Assim, nunca é possível criar um dono em estado inválido. */
public class Dono : BaseEntity
{
    // Nome completo do dono
    public string Nome { get; private set; } = default!;

    // CPF armazenado apenas com dígitos (sem pontuação), usando o Value Object Cpf
    public string CpfValor { get; private set; } = default!;

    // E-mail armazenado e validado pelo Value Object Email
    public string EmailValor { get; private set; } = default!;

    // Telefone com DDD (10 ou 11 dígitos)
    public string Telefone { get; private set; } = default!;

    // Endereço completo do dono
    public string Endereco { get; private set; } = default!;

    // Hash da senha gerado com BCrypt — nunca armazenamos a senha em texto puro
    public string SenhaHash { get; private set; } = default!;

    // Lista interna de pets — encapsulada para controlar o acesso externo
    private readonly List<Pet> _pets = new();

    // Exposição somente leitura dos pets — o código externo não pode modificar diretamente a lista
    public IReadOnlyCollection<Pet> Pets => _pets.AsReadOnly();

    // Construtor sem parâmetros exigido pelo Entity Framework para reconstruir objetos do banco
    protected Dono() { }

    // Construtor privado — usado apenas pelo método fábrica Criar()
    // Garante que o objeto só seja criado com dados já validados
    private Dono(string nome, Cpf cpf, Email email, string telefone, string endereco, string senhaHash)
    {
        Nome = nome;
        CpfValor = cpf.Valor;
        EmailValor = email.Valor;
        Telefone = telefone;
        Endereco = endereco;
        SenhaHash = senhaHash;
    }

    // Método fábrica — única forma pública de criar um Dono.
    // Valida todos os dados antes de criar o objeto, garantindo consistência.
    public static Dono Criar(string nome, string cpf, string email, string telefone, string endereco, string senhaHash)
    {
        ValidarNome(nome);
        ValidarTelefone(telefone);
        ValidarEndereco(endereco);
        if (string.IsNullOrWhiteSpace(senhaHash))
            throw new DomainException("Senha e obrigatoria.");

        // Os Value Objects Cpf e Email já fazem suas próprias validações de formato
        var cpfVo = Cpf.Criar(cpf);
        var emailVo = Email.Criar(email);

        return new Dono(nome, cpfVo, emailVo, telefone, endereco, senhaHash);
    }

    // Atualiza os dados do dono — o CPF não pode ser alterado após o cadastro
    public void Atualizar(string nome, string email, string telefone, string endereco)
    {
        ValidarNome(nome);
        ValidarTelefone(telefone);
        ValidarEndereco(endereco);

        Nome = nome;
        EmailValor = Email.Criar(email).Valor;
        Telefone = telefone;
        Endereco = endereco;
        SetUpdatedAt(); // Registra a data de atualização na BaseEntity
    }

    // Troca a senha do dono — recebe o novo hash gerado com BCrypt
    public void AlterarSenha(string novaSenhaHash)
    {
        if (string.IsNullOrWhiteSpace(novaSenhaHash))
            throw new DomainException("Nova senha invalida.");
        SenhaHash = novaSenhaHash;
        SetUpdatedAt();
    }

    // Adiciona um pet à lista do dono
    public void AdicionarPet(Pet pet)
    {
        if (pet == null) throw new DomainException("Pet invalido.");
        _pets.Add(pet);
    }

    // Validações internas — usadas pelo Criar() e Atualizar()
    private static void ValidarNome(string nome)
    {
        if (string.IsNullOrWhiteSpace(nome))
            throw new DomainException("Nome do dono e obrigatorio.");
        if (nome.Length < 3 || nome.Length > 150)
            throw new DomainException("Nome deve ter entre 3 e 150 caracteres.");
    }

    // Verifica se o telefone tem entre 10 e 11 dígitos numéricos (DDD + número)
    private static void ValidarTelefone(string telefone)
    {
        if (string.IsNullOrWhiteSpace(telefone))
            throw new DomainException("Telefone e obrigatorio.");
        var digits = new string(telefone.Where(char.IsDigit).ToArray());
        if (digits.Length < 10 || digits.Length > 11)
            throw new DomainException("Telefone invalido. Informe DDD + numero.");
    }

    private static void ValidarEndereco(string endereco)
    {
        if (string.IsNullOrWhiteSpace(endereco))
            throw new DomainException("Endereco e obrigatorio.");
    }
}
