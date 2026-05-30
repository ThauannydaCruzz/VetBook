using FluentAssertions;
using VetBook.CadastroContext.Domain.Entities;
using VetBook.SharedKernel.Exceptions;
using VetBook.SharedKernel.ValueObjects;

namespace VetBook.Tests.Unit.CadastroContext;

public class DonoTests
{
    [Fact]
    public void Criar_ComDadosValidos_DeveCriarDono()
    {
        var dono = Dono.Criar("João Silva", "529.982.247-25", "joao@email.com", "11987654321", "Rua A, 123");

        dono.Should().NotBeNull();
        dono.Nome.Should().Be("João Silva");
        dono.CpfValor.Should().Be("52998224725");
        dono.EmailValor.Should().Be("joao@email.com");
        dono.Id.Should().NotBe(Guid.Empty);
        dono.DataCadastro.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(5));
    }

    [Theory]
    [InlineData("")]
    [InlineData("  ")]
    [InlineData("AB")]
    public void Criar_ComNomeInvalido_DeveLancarExcecao(string nome)
    {
        var act = () => Dono.Criar(nome, "529.982.247-25", "joao@email.com", "11987654321", "Rua A");
        act.Should().Throw<DomainException>();
    }

    [Theory]
    [InlineData("111.111.111-11")]
    [InlineData("000.000.000-00")]
    [InlineData("123.456.789-00")]
    public void Criar_ComCpfInvalido_DeveLancarExcecao(string cpf)
    {
        var act = () => Dono.Criar("João Silva", cpf, "joao@email.com", "11987654321", "Rua A");
        act.Should().Throw<DomainException>();
    }

    [Fact]
    public void Atualizar_ComDadosValidos_DeveAtualizarDono()
    {
        var dono = Dono.Criar("João Silva", "529.982.247-25", "joao@email.com", "11987654321", "Rua A");

        dono.Atualizar("João Santos", "novo@email.com", "11999999999", "Rua B, 456");

        dono.Nome.Should().Be("João Santos");
        dono.EmailValor.Should().Be("novo@email.com");
        dono.DataAtualizacao.Should().NotBeNull();
    }

    [Fact]
    public void CpfValueObject_Valido_DeveRetornarFormatado()
    {
        var cpf = Cpf.Criar("529.982.247-25");
        cpf.Formatado().Should().Be("529.982.247-25");
        cpf.Valor.Should().Be("52998224725");
    }

    [Fact]
    public void CpfValueObject_Invalido_DeveLancarExcecao()
    {
        var act = () => Cpf.Criar("111.111.111-11");
        act.Should().Throw<DomainException>().WithMessage("CPF inválido.");
    }

    [Fact]
    public void EmailValueObject_Valido_DeveNormalizarParaMinusculo()
    {
        var email = Email.Criar("JOAO@EMAIL.COM");
        email.Valor.Should().Be("joao@email.com");
    }

    [Theory]
    [InlineData("emailsemarroba")]
    [InlineData("@email.com")]
    [InlineData("email@")]
    public void EmailValueObject_Invalido_DeveLancarExcecao(string email)
    {
        var act = () => Email.Criar(email);
        act.Should().Throw<DomainException>();
    }
}
