namespace VetBook.SharedKernel.Common;

/* Classe genérica de resposta padronizada da API.
 * Todas as respostas seguem o mesmo formato: success, message, data e errors.
 * Isso facilita o tratamento no frontend — sempre o mesmo contrato. */
public class ApiResponse<T>
{
    // Indica se a operação foi bem-sucedida (true) ou falhou (false)
    public bool Success { get; set; }

    // Mensagem descritiva do resultado — exibida ao usuário
    public string Message { get; set; } = string.Empty;

    // Dados retornados pela operação — null em caso de erro
    public T? Data { get; set; }

    // Lista de erros de validação quando Success = false
    public IEnumerable<string>? Errors { get; set; }

    // Factory method para respostas de sucesso com dados
    public static ApiResponse<T> Ok(T data, string message = "Operação realizada com sucesso.")
        => new() { Success = true, Message = message, Data = data };

    // Factory method para respostas de erro com mensagem e erros detalhados
    public static ApiResponse<T> Fail(string message, IEnumerable<string>? errors = null)
        => new() { Success = false, Message = message, Errors = errors };
}

// Versão sem dados genéricos — usada em operações que não retornam payload (ex: DELETE)
public class ApiResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public IEnumerable<string>? Errors { get; set; }

    public static ApiResponse Ok(string message = "Operação realizada com sucesso.")
        => new() { Success = true, Message = message };

    public static ApiResponse Fail(string message, IEnumerable<string>? errors = null)
        => new() { Success = false, Message = message, Errors = errors };
}
