using FluentValidation;
using VetBook.VeterinarioContext.Application.DTOs;

namespace VetBook.VeterinarioContext.Application.Validators;

// Validador FluentValidation para criação de veterinário.
// Executado automaticamente pelo pipeline da API antes do Use Case.
public class CreateVeterinarioValidator : AbstractValidator<CreateVeterinarioRequest>
{
    public CreateVeterinarioValidator()
    {
        RuleFor(x => x.Nome)
            .NotEmpty().WithMessage("Nome é obrigatório.")
            .Length(3, 150).WithMessage("Nome deve ter entre 3 e 150 caracteres.");

        // CRMV deve ter formato SP-12345 — entre 5 e 20 caracteres
        RuleFor(x => x.Crmv)
            .NotEmpty().WithMessage("CRMV é obrigatório.")
            .Length(5, 20).WithMessage("CRMV inválido. Ex: SP-12345.");

        RuleFor(x => x.Especialidade)
            .NotEmpty().WithMessage("Especialidade é obrigatória.")
            .MaximumLength(100).WithMessage("Especialidade deve ter no máximo 100 caracteres.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail é obrigatório.")
            .EmailAddress().WithMessage("E-mail inválido.");

        // Telefone com 10 ou 11 dígitos (DDD + número com ou sem 9)
        RuleFor(x => x.Telefone)
            .NotEmpty().WithMessage("Telefone é obrigatório.")
            .Must(tel => new string(tel.Where(char.IsDigit).ToArray()).Length is >= 10 and <= 11)
            .WithMessage("Telefone inválido.");
    }
}

// Validador para atualização de veterinário — CRMV não pode ser alterado
public class UpdateVeterinarioValidator : AbstractValidator<UpdateVeterinarioRequest>
{
    public UpdateVeterinarioValidator()
    {
        RuleFor(x => x.Nome)
            .NotEmpty().WithMessage("Nome é obrigatório.")
            .Length(3, 150).WithMessage("Nome deve ter entre 3 e 150 caracteres.");

        RuleFor(x => x.Especialidade)
            .NotEmpty().WithMessage("Especialidade é obrigatória.")
            .MaximumLength(100).WithMessage("Especialidade deve ter no máximo 100 caracteres.");

        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail é obrigatório.")
            .EmailAddress().WithMessage("E-mail inválido.");

        RuleFor(x => x.Telefone)
            .NotEmpty().WithMessage("Telefone é obrigatório.")
            .Must(tel => new string(tel.Where(char.IsDigit).ToArray()).Length is >= 10 and <= 11)
            .WithMessage("Telefone inválido.");
    }
}
