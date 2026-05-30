using FluentAssertions;
using VetBook.AgendamentoContext.Domain.Entities;
using VetBook.AgendamentoContext.Domain.Enums;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.Tests.Unit.AgendamentoContext;

public class ConsultaTests
{
    private static readonly Guid PetId = Guid.NewGuid();
    private static readonly Guid VetId = Guid.NewGuid();
    private static readonly DateTime DataFutura = DateTime.UtcNow.AddDays(1);

    [Fact]
    public void Criar_ComDadosValidos_DeveCriarConsulta()
    {
        var consulta = Consulta.Criar(PetId, VetId, DataFutura, "Consulta de rotina", null);

        consulta.Should().NotBeNull();
        consulta.PetId.Should().Be(PetId);
        consulta.VeterinarioId.Should().Be(VetId);
        consulta.StatusConsulta.Should().Be(StatusConsulta.Agendada);
    }

    [Fact]
    public void Criar_ComDataPassada_DeveLancarExcecao()
    {
        var dataPassada = DateTime.UtcNow.AddDays(-1);
        var act = () => Consulta.Criar(PetId, VetId, dataPassada, "Consulta", null);
        act.Should().Throw<DomainException>().WithMessage("*data*futura*");
    }

    [Fact]
    public void Criar_ComMotivoVazio_DeveLancarExcecao()
    {
        var act = () => Consulta.Criar(PetId, VetId, DataFutura, "", null);
        act.Should().Throw<DomainException>().WithMessage("*Motivo*");
    }

    [Fact]
    public void Confirmar_ConsultaAgendada_DeveConfirmar()
    {
        var consulta = Consulta.Criar(PetId, VetId, DataFutura, "Consulta de rotina", null);

        consulta.Confirmar();

        consulta.StatusConsulta.Should().Be(StatusConsulta.Confirmada);
    }

    [Fact]
    public void Cancelar_ConsultaAgendada_DeveCancelar()
    {
        var consulta = Consulta.Criar(PetId, VetId, DataFutura, "Consulta de rotina", null);

        consulta.Cancelar("Motivo do cancelamento");

        consulta.StatusConsulta.Should().Be(StatusConsulta.Cancelada);
        consulta.Observacoes.Should().Be("Motivo do cancelamento");
    }

    [Fact]
    public void Cancelar_ConsultaFinalizada_DeveLancarExcecao()
    {
        var consulta = Consulta.Criar(PetId, VetId, DataFutura, "Consulta de rotina", null);
        consulta.Confirmar();
        consulta.Finalizar(null);

        var act = () => consulta.Cancelar(null);
        act.Should().Throw<DomainException>().WithMessage("*finalizada*");
    }

    [Fact]
    public void Finalizar_ConsultaConfirmada_DeveFinalizar()
    {
        var consulta = Consulta.Criar(PetId, VetId, DataFutura, "Consulta de rotina", null);
        consulta.Confirmar();

        consulta.Finalizar("Paciente saudável.");

        consulta.StatusConsulta.Should().Be(StatusConsulta.Finalizada);
        consulta.Observacoes.Should().Be("Paciente saudável.");
    }

    [Fact]
    public void Reagendar_ConsultaAgendada_DeveReagendar()
    {
        var consulta = Consulta.Criar(PetId, VetId, DataFutura, "Consulta de rotina", null);
        var novaData = DateTime.UtcNow.AddDays(3);

        consulta.Reagendar(novaData, "Reagendamento solicitado");

        consulta.DataConsulta.Should().BeCloseTo(novaData, TimeSpan.FromSeconds(1));
    }

    [Fact]
    public void Reagendar_ConsultaCancelada_DeveLancarExcecao()
    {
        var consulta = Consulta.Criar(PetId, VetId, DataFutura, "Consulta de rotina", null);
        consulta.Cancelar(null);

        var act = () => consulta.Reagendar(DateTime.UtcNow.AddDays(2), "Motivo");
        act.Should().Throw<DomainException>().WithMessage("*cancelada*");
    }

    [Fact]
    public void Criar_SemPet_DeveLancarExcecao()
    {
        var act = () => Consulta.Criar(Guid.Empty, VetId, DataFutura, "Consulta", null);
        act.Should().Throw<DomainException>().WithMessage("*Pet*");
    }

    [Fact]
    public void Criar_SemVeterinario_DeveLancarExcecao()
    {
        var act = () => Consulta.Criar(PetId, Guid.Empty, DataFutura, "Consulta", null);
        act.Should().Throw<DomainException>().WithMessage("*Veterinário*");
    }
}
