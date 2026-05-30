using VetBook.SharedKernel.Exceptions;

namespace VetBook.SharedKernel.ValueObjects;

/* Value Object imutável representando um CPF brasileiro válido.
 * Garante que nenhum CPF inválido entre no domínio.
 * O construtor privado obriga o uso do factory method Criar(). */
public sealed class Cpf : IEquatable<Cpf>
{
    // Armazena apenas os 11 dígitos numéricos (sem pontos e traço)
    public string Valor { get; }

    // Construtor privado — use Cpf.Criar() para criar instâncias
    private Cpf(string valor) => Valor = valor;

    // Factory method: valida o CPF e retorna instância ou lança DomainException
    public static Cpf Criar(string cpf)
    {
        // Remove pontos, traços e outros caracteres não numéricos
        var cleaned = new string(cpf.Where(char.IsDigit).ToArray());
        if (!Validar(cleaned))
            throw new DomainException("CPF inválido.");
        return new Cpf(cleaned);
    }

    /* Valida o CPF usando o algoritmo oficial da Receita Federal:
     * 1. Extrai apenas os dígitos
     * 2. Rejeita CPFs com todos os dígitos iguais (ex: 000.000.000-00)
     * 3. Calcula o primeiro dígito verificador (módulo 11)
     * 4. Calcula o segundo dígito verificador */
    public static bool Validar(string cpf)
    {
        var digits = new string(cpf.Where(char.IsDigit).ToArray());
        if (digits.Length != 11) return false;
        if (digits.Distinct().Count() == 1) return false;  // Ex: 111.111.111-11 é inválido

        // Cálculo do primeiro dígito verificador
        var sum = 0;
        for (var i = 0; i < 9; i++) sum += int.Parse(digits[i].ToString()) * (10 - i);
        var remainder = (sum * 10) % 11;
        if (remainder == 10 || remainder == 11) remainder = 0;
        if (remainder != int.Parse(digits[9].ToString())) return false;

        // Cálculo do segundo dígito verificador
        sum = 0;
        for (var i = 0; i < 10; i++) sum += int.Parse(digits[i].ToString()) * (11 - i);
        remainder = (sum * 10) % 11;
        if (remainder == 10 || remainder == 11) remainder = 0;
        return remainder == int.Parse(digits[10].ToString());
    }

    // Retorna o CPF formatado com pontos e traço (ex: 123.456.789-09)
    public string Formatado()
        => $"{Valor[..3]}.{Valor[3..6]}.{Valor[6..9]}-{Valor[9..11]}";

    // Igualdade baseada no valor do CPF (não na referência)
    public bool Equals(Cpf? other) => other is not null && Valor == other.Valor;
    public override bool Equals(object? obj) => obj is Cpf cpf && Equals(cpf);
    public override int GetHashCode() => Valor.GetHashCode();

    // ToString retorna os dígitos puros — formatação é responsabilidade do frontend
    public override string ToString() => Valor;
}
