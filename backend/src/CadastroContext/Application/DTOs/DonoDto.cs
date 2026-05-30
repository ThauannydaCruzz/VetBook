namespace VetBook.CadastroContext.Application.DTOs;

// DTO de entrada para criar um novo dono/tutor de pet.
// A senha é recebida em texto plano e será hasheada antes de salvar.
public record CreateDonoRequest(
    string Nome,
    string Cpf,
    string Email,
    string Telefone,
    string Endereco,
    string Senha
);

// DTO de entrada para atualizar dados do dono.
// CPF e Senha não podem ser alterados via esta rota (segurança).
public record UpdateDonoRequest(
    string Nome,
    string Email,
    string Telefone,
    string Endereco
);

// DTO de saída com os dados do dono retornados pela API.
// Inclui lista resumida dos pets para evitar múltiplas requisições.
public record DonoResponse
{
    public Guid Id { get; init; }
    public string Nome { get; init; } = string.Empty;

    // CPF armazenado apenas com dígitos no banco — formatação no frontend
    public string Cpf { get; init; } = string.Empty;
    public string Email { get; init; } = string.Empty;
    public string Telefone { get; init; } = string.Empty;
    public string Endereco { get; init; } = string.Empty;
    public DateTime DataCadastro { get; init; }

    // Resumo dos pets do dono — evita retornar dados completos desnecessariamente
    public IEnumerable<PetResumoResponse> Pets { get; init; } = [];
}

// Resumo de pet usado dentro do DonoResponse — apenas dados essenciais
public record PetResumoResponse
{
    public Guid Id { get; init; }
    public string Nome { get; init; } = string.Empty;
    public string Especie { get; init; } = string.Empty;
    public string Raca { get; init; } = string.Empty;
}
