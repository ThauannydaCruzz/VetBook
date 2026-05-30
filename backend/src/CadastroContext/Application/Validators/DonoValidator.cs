using FluentValidation;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.SharedKernel.ValueObjects;

namespace VetBook.CadastroContext.Application.Validators;

// Validador FluentValidation para criação de dono.
// Executado automaticamente pelo pipeline da API antes do Use Case ser chamado.
public class CreateDonoValidator : AbstractValidator<CreateDonoRequest>
{
    public CreateDonoValidator()
    {
        // Nome com mínimo de 3 caracteres para evitar abreviações sem sentido
        RuleFor(x => x.Nome)
            .NotEmpty().WithMessage("Nome é obrigatório.")
            .Length(3, 150).WithMessage("Nome deve ter entre 3 e 150 caracteres.");

        // CPF validado com o algoritmo completo do Value Object Cpf
        RuleFor(x => x.Cpf)
            .NotEmpty().WithMessage("CPF é obrigatório.")
            .Must(cpf => Cpf.Validar(cpf)).WithMessage("CPF inválido.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail é obrigatório.")
            .EmailAddress().WithMessage("E-mail inválido.");

        // Telefone deve ter 10 ou 11 dígitos (DDD + número, com ou sem 9)
        RuleFor(x => x.Telefone)
            .NotEmpty().WithMessage("Telefone é obrigatório.")
            .Must(tel => new string(tel.Where(char.IsDigit).ToArray()).Length is >= 10 and <= 11)
            .WithMessage("Telefone inválido. Informe DDD + número (10 ou 11 dígitos).");

        RuleFor(x => x.Endereco)
            .NotEmpty().WithMessage("Endereço é obrigatório.")
            .MaximumLength(300).WithMessage("Endereço muito longo.");
    }
}

// Validador para atualização de dono — mesmas regras, sem CPF e Senha
public class UpdateDonoValidator : AbstractValidator<UpdateDonoRequest>
{
    public UpdateDonoValidator()
    {
        RuleFor(x => x.Nome)
            .NotEmpty().WithMessage("Nome é obrigatório.")
            .Length(3, 150).WithMessage("Nome deve ter entre 3 e 150 caracteres.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail é obrigatório.")
            .EmailAddress().WithMessage("E-mail inválido.");

        RuleFor(x => x.Telefone)
            .NotEmpty().WithMessage("Telefone é obrigatório.")
            .Must(tel => new string(tel.Where(char.IsDigit).ToArray()).Length is >= 10 and <= 11)
            .WithMessage("Telefone inválido.");

        RuleFor(x => x.Endereco)
            .NotEmpty().WithMessage("Endereço é obrigatório.")
            .MaximumLength(300).WithMessage("Endereço muito longo.");
    }
}
