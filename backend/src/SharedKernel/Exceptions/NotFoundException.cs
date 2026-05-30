namespace VetBook.SharedKernel.Exceptions;

/* Exceção lançada quando um recurso buscado por ID não existe no banco.
 * Exemplos: buscar pet com ID inexistente, confirmar consulta que não existe.
 * É capturada pelo middleware global e retornada como HTTP 404. */
public class NotFoundException : Exception
{
    // Construtor principal: gera mensagem formatada com entidade e chave
    // Exemplo: "Pet com identificador '...' não foi encontrado."
    public NotFoundException(string entity, object key)
        : base($"{entity} com identificador '{key}' não foi encontrado.") { }

    // Construtor alternativo com mensagem personalizada
    public NotFoundException(string message) : base(message) { }
}
