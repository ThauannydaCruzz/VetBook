using FluentValidation;
using VetBook.CadastroContext.Application.DTOs;

namespace VetBook.CadastroContext.Application.Validators;

// Validador FluentValidation para criação de pet.
// Garante que os campos essenciais estejam preenchidos com valores coerentes.
public class CreatePetValidator : AbstractValidator<CreatePetRequest>
{
    public CreatePetValidator()
    {
        RuleFor(x => x.Nome)
            .NotEmpty().WithMessage("Nome do pet é obrigatório.")
            .MaximumLength(100).WithMessage("Nome do pet deve ter no máximo 100 caracteres.");

        RuleFor(x => x.Especie)
            .NotEmpty().WithMessage("Espécie é obrigatória.")
            .MaximumLength(50).WithMessage("Espécie deve ter no máximo 50 caracteres.");

        RuleFor(x => x.Raca)
            .NotEmpty().WithMessage("Raça é obrigatória.")
            .MaximumLength(50).WithMessage("Raça deve ter no máximo 50 caracteres.");

        // Permite pets de 0 anos (filhotes recém-nascidos) até 50 anos (tartarugas, etc.)
        RuleFor(x => x.Idade)
            .InclusiveBetween(0, 50).WithMessage("Idade deve estar entre 0 e 50 anos.");

        // Peso deve ser positivo — sem limite realista muito baixo para incluir aves e roedores
        RuleFor(x => x.Peso)
            .GreaterThan(0).WithMessage("Peso deve ser maior que zero.")
            .LessThanOrEqualTo(999).WithMessage("Peso inválido.");

        // DonoId obrigatório — pet sempre pertence a um dono
        RuleFor(x => x.DonoId)
            .NotEmpty().WithMessage("Dono é obrigatório.");

        // Observações são opcionais mas limitadas a 500 caracteres
        RuleFor(x => x.Observacoes)
            .MaximumLength(500).WithMessage("Observações devem ter no máximo 500 caracteres.")
            .When(x => x.Observacoes is not null);
    }
}

// Validador para atualização de pet — mesmas regras sem DonoId
public class UpdatePetValidator : AbstractValidator<UpdatePetRequest>
{
    public UpdatePetValidator()
    {
        RuleFor(x => x.Nome)
            .NotEmpty().WithMessage("Nome do pet é obrigatório.")
            .MaximumLength(100).WithMessage("Nome do pet deve ter no máximo 100 caracteres.");

        RuleFor(x => x.Especie)
            .NotEmpty().WithMessage("Espécie é obrigatória.")
            .MaximumLength(50).WithMessage("Espécie deve ter no máximo 50 caracteres.");

        RuleFor(x => x.Raca)
            .NotEmpty().WithMessage("Raça é obrigatória.")
            .MaximumLength(50).WithMessage("Raça deve ter no máximo 50 caracteres.");

        RuleFor(x => x.Idade)
            .InclusiveBetween(0, 50).WithMessage("Idade deve estar entre 0 e 50 anos.");

        RuleFor(x => x.Peso)
            .GreaterThan(0).WithMessage("Peso deve ser maior que zero.")
            .LessThanOrEqualTo(999).WithMessage("Peso inválido.");
    }
}
