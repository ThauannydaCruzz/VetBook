using FluentAssertions;
using VetBook.SharedKernel.Exceptions;
using VetBook.VeterinarioContext.Domain.Entities;

namespace VetBook.Tests.Unit.VeterinarioContext;

public class VeterinarioTests
{
    [Fact]
    public void Criar_ComDadosValidos_DeveCriarVeterinario()
    {
        var vet = Veterinario.Criar("Dr. Carlos", "SP-12345", "Clínica Geral",
                                    "carlos@vet.com", "11987654321");

        vet.Should().NotBeNull();
        vet.Nome.Should().Be("Dr. Carlos");
        vet.Crmv.Should().Be("SP-12345");
        vet.Especialidade.Should().Be("Clínica Geral");
        vet.Ativo.Should().BeTrue();
    }

    [Theory]
    [InlineData("")]
    [InlineData("AB")]
    public void Criar_ComCrmvInvalido_DeveLancarExcecao(string crmv)
    {
        var act = () => Veterinario.Criar("Dr. Carlos", crmv, "Clínica Geral",
                                          "carlos@vet.com", "11987654321");
        act.Should().Throw<DomainException>();
    }

    [Fact]
    public void Inativar_VeterinarioAtivo_DeveInativar()
    {
        var vet = Veterinario.Criar("Dr. Carlos", "SP-12345", "Clínica Geral",
                                    "carlos@vet.com", "11987654321");

        vet.Inativar();

        vet.Ativo.Should().BeFalse();
        vet.DataAtualizacao.Should().NotBeNull();
    }

    [Fact]
    public void Ativar_VeterinarioInativo_DeveAtivar()
    {
        var vet = Veterinario.Criar("Dr. Carlos", "SP-12345", "Clínica Geral",
                                    "carlos@vet.com", "11987654321");
        vet.Inativar();

        vet.Ativar();

        vet.Ativo.Should().BeTrue();
    }

    [Fact]
    public void Atualizar_ComDadosValidos_DeveAtualizarVeterinario()
    {
        var vet = Veterinario.Criar("Dr. Carlos", "SP-12345", "Clínica Geral",
                                    "carlos@vet.com", "11987654321");

        vet.Atualizar("Dr. Carlos Silva", "Ortopedia", "novo@email.com", "11999999999");

        vet.Nome.Should().Be("Dr. Carlos Silva");
        vet.Especialidade.Should().Be("Ortopedia");
        vet.Crmv.Should().Be("SP-12345"); // CRMV não muda
    }
}
