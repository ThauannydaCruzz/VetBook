using Serilog;
using VetBook.API.Extensions;
using VetBook.API.Middlewares;

// O Npgsql (driver do PostgreSQL) precisa dessa configuração para tratar DateTime como UTC.
// Sem isso, as datas podem ser rejeitadas pelo banco com erro de timezone.
AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

// Configuração do Serilog — loga no console e em arquivo rotativo diário
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .WriteTo.File("logs/vetbook-.txt", rollingInterval: RollingInterval.Day)
    .Enrich.FromLogContext()
    .CreateLogger();

try
{
    Log.Information("Iniciando VetBook API com Supabase PostgreSQL...");

    var builder = WebApplication.CreateBuilder(args);

    // Substitui o logger padrão do ASP.NET pelo Serilog
    builder.Host.UseSerilog();

    builder.Services.AddControllers();
    builder.Services.AddEndpointsApiExplorer();

    // Registra todos os serviços do sistema usando métodos de extensão organizados por responsabilidade.
    // Cada método cuida de uma parte: banco de dados, repositórios, use cases, etc.
    builder.Services
        .AddDatabase(builder.Configuration)
        .AddRepositories()
        .AddUnitOfWorks()
        .AddAutoMapperProfiles()
        .AddValidators()
        .AddUseCases()
        .AddApplicationServices()
        .AddJwtAuthentication(builder.Configuration)
        .AddSwagger()
        .AddCorsPolicy();

    var app = builder.Build();

    // Testa a conexão com o banco Supabase ao iniciar — apenas para diagnóstico.
    // Se falhar, a API ainda sobe mas registra um aviso nos logs.
    using (var scope = app.Services.CreateScope())
    {
        try
        {
            var cadastro = scope.ServiceProvider
                .GetRequiredService<VetBook.CadastroContext.Infrastructure.Data.CadastroDbContext>();
            var podeConectar = cadastro.Database.CanConnect();
            if (podeConectar)
                Log.Information("Conexao com Supabase PostgreSQL estabelecida com sucesso.");
            else
                Log.Warning("Nao foi possivel conectar ao Supabase. Verifique a senha na connection string.");
        }
        catch (Exception ex)
        {
            Log.Warning(ex, "Erro ao verificar conexao com Supabase. Verifique a connection string em appsettings.json.");
        }
    }

    // Middleware de tratamento global de erros — captura exceções não tratadas e retorna JSON padronizado
    app.UseMiddleware<GlobalExceptionMiddleware>();

    // Swagger — interface visual para testar a API no navegador
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "VetBook API v1");
        c.RoutePrefix = string.Empty; // Swagger fica na raiz: http://localhost:5000/
        c.DocumentTitle = "VetBook API";
        c.DefaultModelsExpandDepth(1);
        c.DefaultModelExpandDepth(2);
        c.DisplayRequestDuration();
        c.EnableFilter();
        c.EnableDeepLinking();
    });

    // Logging de requisições HTTP pelo Serilog
    app.UseSerilogRequestLogging();

    // CORS — permite que o app Flutter (e outros clientes) acesse a API de qualquer origem
    app.UseCors("AllowAll");

    // Autenticação e autorização JWT — valida o token Bearer em cada requisição protegida
    app.UseAuthentication();
    app.UseAuthorization();

    // Mapeia todas as controllers automaticamente
    app.MapControllers();

    // Endpoint simples de health check — útil para verificar se a API está rodando
    app.MapGet("/health", () => new { Status = "Healthy", Timestamp = DateTime.UtcNow, Database = "Supabase PostgreSQL" });

    Log.Information("VetBook API iniciada com sucesso.");
    app.Run();
}
catch (Exception ex)
{
    // Se algo crítico falhar na inicialização, registra e repropaga o erro
    Log.Fatal(ex, "Falha critica ao iniciar a aplicacao.");
    throw;
}
finally
{
    // Garante que todos os logs pendentes sejam gravados antes de encerrar
    Log.CloseAndFlush();
}

public partial class Program { }
