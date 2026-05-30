using System.Net;
using System.Text.Json;
using VetBook.SharedKernel.Common;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.API.Middlewares;

/* Middleware de tratamento global de exceções.
 * Em vez de deixar erros não tratados causarem respostas genéricas ou até quebrar a API,
 * este middleware intercepta qualquer exceção e retorna uma resposta JSON padronizada.
 * Ele fica no início do pipeline — envolve toda a requisição num try/catch. */
public class GlobalExceptionMiddleware
{
    // Delegate que representa o próximo middleware na fila do pipeline
    private readonly RequestDelegate _next;

    // Logger para registrar os erros com detalhes
    private readonly ILogger<GlobalExceptionMiddleware> _logger;

    public GlobalExceptionMiddleware(RequestDelegate next, ILogger<GlobalExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    // Método chamado automaticamente pelo ASP.NET para cada requisição.
    // Tenta executar o restante do pipeline e, se alguma exceção não tratada ocorrer, captura aqui.
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro nao tratado: {Message}", ex.Message);
            await HandleExceptionAsync(context, ex);
        }
    }

    // Converte a exceção capturada em uma resposta HTTP com status code e mensagem apropriados.
    // Usa pattern matching para identificar o tipo de exceção e retornar o status correto.
    private static async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var (statusCode, response) = exception switch
        {
            // Exceções de domínio (regras de negócio violadas) → 400 Bad Request
            DomainException domainEx => (HttpStatusCode.BadRequest,
                ApiResponse.Fail(domainEx.Message)),

            // Recurso não encontrado → 404 Not Found
            NotFoundException notFoundEx => (HttpStatusCode.NotFound,
                ApiResponse.Fail(notFoundEx.Message)),

            // Acesso negado → 401 Unauthorized
            UnauthorizedAccessException => (HttpStatusCode.Unauthorized,
                ApiResponse.Fail("Acesso nao autorizado.")),

            // Qualquer outro erro inesperado → 500 Internal Server Error (sem expor detalhes internos)
            _ => (HttpStatusCode.InternalServerError,
                ApiResponse.Fail("Ocorreu um erro interno. Por favor, tente novamente."))
        };

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;

        // Serializa a resposta como JSON usando camelCase (padrão do frontend)
        var json = JsonSerializer.Serialize(response, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(json);
    }
}
