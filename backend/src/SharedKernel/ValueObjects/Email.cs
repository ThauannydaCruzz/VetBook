using System.Text.RegularExpressions;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.SharedKernel.ValueObjects;

/* Value Object imutável representando um endereço de e-mail válido.
 * Garante formato correto e normaliza para lowercase antes de salvar.
 * O construtor privado obriga o uso do factory method Criar(). */
public sealed class Email : IEquatable<Email>
{
    // Regex compilada uma vez e reutilizada — padrão básico: algo@dominio.extensao
    private static readonly Regex EmailRegex =
        new(@"^[^@\s]+@[^@\s]+\.[^@\s]+$", RegexOptions.Compiled | RegexOptions.IgnoreCase);

    // E-mail normalizado em lowercase — evita duplicatas por capitalização
    public string Valor { get; }

    // Construtor privado — normaliza para lowercase ao criar
    private Email(string valor) => Valor = valor.ToLowerInvariant();

    // Factory method: valida e cria um Email ou lança DomainException
    public static Email Criar(string email)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new DomainException("E-mail não pode ser vazio.");
        if (!EmailRegex.IsMatch(email))
            throw new DomainException("E-mail inválido.");
        return new Email(email);
    }

    // Igualdade baseada no valor do e-mail (já em lowercase)
    public bool Equals(Email? other) => other is not null && Valor == other.Valor;
    public override bool Equals(object? obj) => obj is Email e && Equals(e);
    public override int GetHashCode() => Valor.GetHashCode();
    public override string ToString() => Valor;
}
