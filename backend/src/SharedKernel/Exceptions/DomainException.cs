namespace VetBook.SharedKernel.Exceptions;

/* Exceção lançada quando uma regra de negócio do domínio é violada.
 * Exemplos: tentar remover dono com pets, cancelar consulta já finalizada.
 * É capturada pelo middleware global de exceções e retornada como HTTP 400. */
public class DomainException : Exception
{
    public DomainException(string message) : base(message) { }
    public DomainException(string message, Exception innerException) : base(message, innerException) { }
}
