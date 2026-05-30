using FluentValidation;
using VetBook.AgendamentoContext.Application.DTOs;

namespace VetBook.AgendamentoContext.Application.Validators;

// Validador FluentValidation para criação de consultas.
// É executado automaticamente pelo pipeline da API antes do Use Case ser chamado.
public class CreateConsultaValidator : AbstractValidator<CreateConsultaRequest>
{
    public CreateConsultaValidator()
    {
        // Pet e veterinário são obrigatórios — GUIDs não podem ser vazios
        RuleFor(x => x.PetId)
            .NotEmpty().WithMessage("Pet é obrigatório.");

        RuleFor(x => x.VeterinarioId)
            .NotEmpty().WithMessage("Veterinário é obrigatório.");

        // A data deve ser futura — não é possível agendar no passado
        RuleFor(x => x.DataConsulta)
            .NotEmpty().WithMessage("Data da consulta é obrigatória.")
            .GreaterThan(DateTime.Now).WithMessage("A data da consulta deve ser futura.");

        // Motivo é obrigatório e tem limite de 500 caracteres
        RuleFor(x => x.MotivoConsulta)
            .NotEmpty().WithMessage("Motivo da consulta é obrigatório.")
            .MaximumLength(500).WithMessage("Motivo deve ter no máximo 500 caracteres.");

        // Observações são opcionais, mas limitadas a 500 caracteres se informadas
        RuleFor(x => x.Observacoes)
            .MaximumLength(500).WithMessage("Observações devem ter no máximo 500 caracteres.")
            .When(x => x.Observacoes is not null);
    }
}

// Validador para reagendamento de consulta — exige nova data futura e motivo
public class UpdateConsultaValidator : AbstractValidator<UpdateConsultaRequest>
{
    public UpdateConsultaValidator()
    {
        RuleFor(x => x.DataConsulta)
            .NotEmpty().WithMessage("Data da consulta é obrigatória.")
            .GreaterThan(DateTime.Now).WithMessage("A data da consulta deve ser futura.");

        RuleFor(x => x.MotivoConsulta)
            .NotEmpty().WithMessage("Motivo da consulta é obrigatório.")
            .MaximumLength(500).WithMessage("Motivo deve ter no máximo 500 caracteres.");
    }
}
