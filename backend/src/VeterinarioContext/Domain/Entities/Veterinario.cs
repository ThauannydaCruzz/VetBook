using VetBook.SharedKernel.Entities;
using VetBook.SharedKernel.Exceptions;
using VetBook.SharedKernel.ValueObjects;

namespace VetBook.VeterinarioContext.Domain.Entities;

/* Entidade de domínio que representa um Veterinário.
 * Segue o padrão DDD: toda criação e modificação passa por métodos que validam as regras.
 * O campo Ativo controla se o veterinário está disponível para agendamentos. */
public class Veterinario : BaseEntity
{
    // Nome completo do veterinário
    public string Nome         { get; private set; } = default!;

    // CRMV — registro profissional no formato UF-XXXXX (ex: SP-12345)
    public string Crmv         { get; private set; } = default!;

    // Especialidade (ex: "Clínica Geral", "Cardiologia", "Ortopedia")
    public string Especialidade { get; private set; } = default!;

    // E-mail validado pelo Value Object Email
    public string EmailValor   { get; private set; } = default!;

    // Telefone com DDD
    public string Telefone     { get; private set; } = default!;

    // Indica se o veterinário está disponível para agendamentos
    public bool   Ativo        { get; private set; }

    // ID da clínica onde este veterinário trabalha (opcional — pode ser autônomo)
    public Guid?  ClinicaId    { get; private set; }

    // Propriedade de navegação — carregada com Include() pelo Entity Framework
    public Clinica? Clinica { get; private set; }

    // Construtor sem parâmetros exigido pelo Entity Framework
    protected Veterinario() { }

    // Construtor privado — chamado apenas pelo método fábrica Criar()
    private Veterinario(string nome, string crmv, string especialidade,
                        Email email, string telefone, Guid? clinicaId)
    {
        Nome         = nome;
        Crmv         = crmv;
        Especialidade = especialidade;
        EmailValor   = email.Valor;
        Telefone     = telefone;
        Ativo        = true; // Todo veterinário começa ativo por padrão
        ClinicaId    = clinicaId;
    }

    // Método fábrica — única forma pública de criar um Veterinario válido
    public static Veterinario Criar(string nome, string crmv, string especialidade,
                                    string email, string telefone, Guid? clinicaId = null)
    {
        ValidarNome(nome);
        ValidarCrmv(crmv);
        ValidarEspecialidade(especialidade);
        ValidarTelefone(telefone);

        var emailVo = Email.Criar(email);
        // O CRMV é armazenado em maiúsculas sem espaços extras
        return new Veterinario(nome, crmv.ToUpper().Trim(), especialidade, emailVo, telefone, clinicaId);
    }

    // Atualiza os dados do veterinário — o CRMV não pode ser alterado após o cadastro
    public void Atualizar(string nome, string especialidade, string email, string telefone, Guid? clinicaId)
    {
        ValidarNome(nome);
        ValidarEspecialidade(especialidade);
        ValidarTelefone(telefone);

        Nome         = nome;
        Especialidade = especialidade;
        EmailValor   = Email.Criar(email).Valor;
        Telefone     = telefone;
        ClinicaId    = clinicaId;
        SetUpdatedAt();
    }

    // Ativa o veterinário — ele volta a aparecer para agendamentos
    public void Ativar()   { Ativo = true;  SetUpdatedAt(); }

    // Inativa o veterinário — ele deixa de aparecer para novos agendamentos
    public void Inativar() { Ativo = false; SetUpdatedAt(); }

    // Validações internas
    private static void ValidarNome(string nome)
    {
        if (string.IsNullOrWhiteSpace(nome))
            throw new DomainException("Nome do veterinario e obrigatorio.");
        if (nome.Length < 3 || nome.Length > 150)
            throw new DomainException("Nome deve ter entre 3 e 150 caracteres.");
    }

    // CRMV deve ter entre 5 e 20 caracteres (ex: "SP-12345")
    private static void ValidarCrmv(string crmv)
    {
        if (string.IsNullOrWhiteSpace(crmv))
            throw new DomainException("CRMV e obrigatorio.");
        if (crmv.Length < 5 || crmv.Length > 20)
            throw new DomainException("CRMV invalido. Informe no formato UF-XXXXX (ex: SP-12345).");
    }

    private static void ValidarEspecialidade(string especialidade)
    {
        if (string.IsNullOrWhiteSpace(especialidade))
            throw new DomainException("Especialidade e obrigatoria.");
    }

    // Telefone deve ter entre 10 e 11 dígitos numéricos (DDD + número)
    private static void ValidarTelefone(string telefone)
    {
        if (string.IsNullOrWhiteSpace(telefone))
            throw new DomainException("Telefone e obrigatorio.");
        var digits = new string(telefone.Where(char.IsDigit).ToArray());
        if (digits.Length < 10 || digits.Length > 11)
            throw new DomainException("Telefone invalido.");
    }
}
