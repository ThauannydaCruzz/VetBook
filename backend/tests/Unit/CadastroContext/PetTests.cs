using FluentAssertions;
using VetBook.CadastroContext.Domain.Entities;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.Tests.Unit.CadastroContext;

public class PetTests
{
    private static readonly Guid DonoId = Guid.NewGuid();

    [Fact]
    public void Criar_ComDadosValidos_DeveCriarPet()
    {
        var pet = Pet.Criar("Rex", "Cachorro", "Labrador", 3, 25.5m, SexoPet.Macho, null, DonoId);

        pet.Should().NotBeNull();
        pet.Nome.Should().Be("Rex");
        pet.Especie.Should().Be("Cachorro");
        pet.Raca.Should().Be("Labrador");
        pet.Idade.Should().Be(3);
        pet.Peso.Should().Be(25.5m);
        pet.Sexo.Should().Be(SexoPet.Macho);
        pet.DonoId.Should().Be(DonoId);
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    public void Criar_ComNomeVazio_DeveLancarExcecao(string nome)
    {
        var act = () => Pet.Criar(nome, "Cachorro", "Labrador", 3, 25m, SexoPet.Macho, null, DonoId);
        act.Should().Throw<DomainException>();
    }

    [Theory]
    [InlineData(-1)]
    [InlineData(51)]
    public void Criar_ComIdadeInvalida_DeveLancarExcecao(int idade)
    {
        var act = () => Pet.Criar("Rex", "Cachorro", "Labrador", idade, 25m, SexoPet.Macho, null, DonoId);
        act.Should().Throw<DomainException>().WithMessage("*Idade*");
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-5)]
    public void Criar_ComPesoZeroOuNegativo_DeveLancarExcecao(decimal peso)
    {
        var act = () => Pet.Criar("Rex", "Cachorro", "Labrador", 3, peso, SexoPet.Macho, null, DonoId);
        act.Should().Throw<DomainException>().WithMessage("*Peso*");
    }

    [Fact]
    public void Criar_SemDono_DeveLancarExcecao()
    {
        var act = () => Pet.Criar("Rex", "Cachorro", "Labrador", 3, 25m, SexoPet.Macho, null, Guid.Empty);
        act.Should().Throw<DomainException>().WithMessage("*Dono*");
    }

    [Fact]
    public void Atualizar_ComDadosValidos_DeveAtualizarPet()
    {
        var pet = Pet.Criar("Rex", "Cachorro", "Labrador", 3, 25m, SexoPet.Macho, null, DonoId);

        pet.Atualizar("Rex Updated", "Cachorro", "Golden", 4, 28m, SexoPet.Macho, "Observação");

        pet.Nome.Should().Be("Rex Updated");
        pet.Raca.Should().Be("Golden");
        pet.Idade.Should().Be(4);
        pet.DataAtualizacao.Should().NotBeNull();
    }
}
