using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using VetBook.AgendamentoContext.Application.Interfaces;
using VetBook.AgendamentoContext.Application.Mappings;
using VetBook.AgendamentoContext.Application.Services;
using VetBook.AgendamentoContext.Application.UseCases;
using VetBook.AgendamentoContext.Application.Validators;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.AgendamentoContext.Infrastructure.Data;
using VetBook.AgendamentoContext.Infrastructure.Repositories;
using VetBook.API.Authentication;
using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Application.Mappings;
using VetBook.CadastroContext.Application.Services;
using VetBook.CadastroContext.Application.UseCases.Donos;
using VetBook.CadastroContext.Application.UseCases.Pets;
using VetBook.CadastroContext.Application.Validators;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.CadastroContext.Infrastructure.Data;
using VetBook.CadastroContext.Infrastructure.Repositories;
using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Application.Mappings;
using VetBook.VeterinarioContext.Application.Services;
using VetBook.VeterinarioContext.Application.UseCases;
using VetBook.VeterinarioContext.Application.Validators;
using VetBook.VeterinarioContext.Domain.Interfaces;
using VetBook.VeterinarioContext.Infrastructure.Data;
using VetBook.VeterinarioContext.Infrastructure.Repositories;

namespace VetBook.API.Extensions;

/* Classe de extensões que organiza o registro de todos os serviços da aplicação.
 * Em vez de colocar tudo no Program.cs (o que ficaria enorme),
 * separamos em métodos por responsabilidade. Cada método cuida de um grupo de serviços.
 * O padrão "this IServiceCollection" permite chamar esses métodos como se fossem da própria coleção. */
public static class ServiceCollectionExtensions
{
    // Conecta os três DbContexts ao banco PostgreSQL do Supabase.
    // Cada contexto gerencia apenas as tabelas do seu próprio "contexto de domínio" (DDD).
    // EnableRetryOnFailure garante que a conexão seja tentada novamente em caso de falha temporária.
    public static IServiceCollection AddDatabase(this IServiceCollection services, IConfiguration config)
    {
        var connStr = config.GetConnectionString("DefaultConnection")!;

        // Todos os contextos apontam para o mesmo banco, mas mapeiam tabelas diferentes
        services.AddDbContext<CadastroDbContext>(opt =>
            opt.UseNpgsql(connStr, npgsql =>
                npgsql.EnableRetryOnFailure(3)));

        services.AddDbContext<VeterinarioDbContext>(opt =>
            opt.UseNpgsql(connStr, npgsql =>
                npgsql.EnableRetryOnFailure(3)));

        services.AddDbContext<AgendamentoDbContext>(opt =>
            opt.UseNpgsql(connStr, npgsql =>
                npgsql.EnableRetryOnFailure(3)));

        return services;
    }

    // Registra os repositórios — cada repositório sabe como acessar o banco para sua entidade.
    // AddScoped significa que uma nova instância é criada por requisição HTTP.
    public static IServiceCollection AddRepositories(this IServiceCollection services)
    {
        services.AddScoped<IDonoRepository, DonoRepository>();
        services.AddScoped<IPetRepository, PetRepository>();
        services.AddScoped<IVeterinarioRepository, VeterinarioRepository>();
        services.AddScoped<IClinicaRepository, ClinicaRepository>();
        services.AddScoped<IConsultaRepository, ConsultaRepository>();
        return services;
    }

    // Registra as Units of Work — responsáveis por commitar as transações no banco.
    // O padrão Unit of Work agrupa operações e salva tudo de uma vez.
    public static IServiceCollection AddUnitOfWorks(this IServiceCollection services)
    {
        services.AddScoped<ICadastroUnitOfWork, CadastroUnitOfWork>();
        services.AddScoped<IVeterinarioUnitOfWork, VeterinarioUnitOfWork>();
        services.AddScoped<IAgendamentoUnitOfWork, AgendamentoUnitOfWork>();
        return services;
    }

    // Registra todos os Use Cases — cada Use Case representa uma ação específica do sistema.
    // Seguindo o padrão DDD/Clean Architecture, cada operação tem sua própria classe.
    public static IServiceCollection AddUseCases(this IServiceCollection services)
    {
        // Use Cases de donos (tutores)
        services.AddScoped<CriarDonoUseCase>();
        services.AddScoped<ValidarCredenciaisDonoUseCase>();
        services.AddScoped<AtualizarDonoUseCase>();
        services.AddScoped<RemoverDonoUseCase>();
        services.AddScoped<ObterDonoUseCase>();
        services.AddScoped<ListarDonosUseCase>();

        // Use Cases de pets (animais)
        services.AddScoped<CriarPetUseCase>();
        services.AddScoped<AtualizarPetUseCase>();
        services.AddScoped<RemoverPetUseCase>();
        services.AddScoped<ObterPetUseCase>();
        services.AddScoped<ListarPetsUseCase>();
        services.AddScoped<ObterPetsPorDonoUseCase>();

        // Use Cases de veterinários
        services.AddScoped<CriarVeterinarioUseCase>();
        services.AddScoped<AtualizarVeterinarioUseCase>();
        services.AddScoped<AtivarVeterinarioUseCase>();
        services.AddScoped<InativarVeterinarioUseCase>();
        services.AddScoped<RemoverVeterinarioUseCase>();
        services.AddScoped<ObterVeterinarioUseCase>();
        services.AddScoped<ListarVeterinariosUseCase>();
        services.AddScoped<ListarVeterinariosAtivosUseCase>();

        // Use Cases de clínicas
        services.AddScoped<CriarClinicaUseCase>();
        services.AddScoped<ListarClinicasUseCase>();
        services.AddScoped<ListarClinicasAtivasUseCase>();
        services.AddScoped<AtualizarClinicaUseCase>();
        services.AddScoped<RemoverClinicaUseCase>();

        // Use Cases de consultas — cobrem todo o ciclo de vida de um agendamento
        services.AddScoped<AgendarConsultaUseCase>();
        services.AddScoped<ReagendarConsultaUseCase>();
        services.AddScoped<ConfirmarConsultaUseCase>();
        services.AddScoped<CancelarConsultaUseCase>();
        services.AddScoped<FinalizarConsultaUseCase>();
        services.AddScoped<ObterConsultaUseCase>();
        services.AddScoped<ListarConsultasUseCase>();
        services.AddScoped<ObterConsultasPorPetUseCase>();
        services.AddScoped<ObterConsultasPorVeterinarioUseCase>();

        return services;
    }

    // Registra os serviços de aplicação — camada que coordena use cases e é chamada pelos controllers.
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IDonoService, DonoService>();
        services.AddScoped<IPetService, PetService>();
        services.AddScoped<IVeterinarioService, VeterinarioService>();
        services.AddScoped<IConsultaService, ConsultaService>();
        return services;
    }

    // Registra os perfis do AutoMapper — ele converte entidades de domínio em DTOs (respostas da API).
    // Por exemplo: Dono → DonoResponse, Consulta → ConsultaResponse.
    public static IServiceCollection AddAutoMapperProfiles(this IServiceCollection services)
    {
        services.AddAutoMapper(cfg =>
        {
            cfg.AddProfile<CadastroMappingProfile>();
            cfg.AddProfile<VeterinarioMappingProfile>();
            cfg.AddProfile<ClinicaMappingProfile>();
            cfg.AddProfile<AgendamentoMappingProfile>();
        });
        return services;
    }

    // Registra os validadores de entrada — verificam se os dados enviados pelo cliente são válidos
    // antes de processar qualquer use case.
    public static IServiceCollection AddValidators(this IServiceCollection services)
    {
        services.AddScoped<CreateDonoValidator>();
        services.AddScoped<UpdateDonoValidator>();
        services.AddScoped<CreatePetValidator>();
        services.AddScoped<UpdatePetValidator>();
        services.AddScoped<CreateVeterinarioValidator>();
        services.AddScoped<UpdateVeterinarioValidator>();
        services.AddScoped<CreateConsultaValidator>();
        services.AddScoped<UpdateConsultaValidator>();
        return services;
    }

    // Configura a autenticação JWT.
    // Lê as configurações do appsettings.json (JwtSettings) e configura o middleware
    // para validar o token em todas as requisições com [Authorize].
    public static IServiceCollection AddJwtAuthentication(this IServiceCollection services, IConfiguration config)
    {
        var jwtSettings = config.GetSection("JwtSettings").Get<JwtSettings>()
            ?? throw new InvalidOperationException("JwtSettings nao configurado.");

        // Registra as configurações JWT e o serviço que gera tokens como Singleton (uma instância para sempre)
        services.AddSingleton(jwtSettings);
        services.AddSingleton<JwtTokenService>();

        // Configura o middleware de autenticação para validar tokens Bearer
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(opt =>
            {
                opt.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer           = true,
                    ValidateAudience         = true,
                    ValidateLifetime         = true,   // Rejeita tokens expirados
                    ValidateIssuerSigningKey = true,   // Verifica se a assinatura é válida
                    ValidIssuer              = jwtSettings.Issuer,
                    ValidAudience            = jwtSettings.Audience,
                    IssuerSigningKey         = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(jwtSettings.SecretKey))
                };
            });

        return services;
    }

    // Configura o Swagger — ferramenta que gera uma interface web para testar a API.
    // Inclui suporte ao token JWT para testar endpoints protegidos diretamente no Swagger.
    public static IServiceCollection AddSwagger(this IServiceCollection services)
    {
        services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("v1", new OpenApiInfo
            {
                Title       = "VetBook API",
                Version     = "v1",
                Description = "Sistema Veterinario - API REST com .NET 8, DDD e Clean Architecture.",
                Contact = new OpenApiContact
                {
                    Name  = "VetBook",
                    Email = "contato@vetbook.com.br",
                    Url   = new Uri("https://github.com/ThauannydaCruzz/VetBook")
                },
                License = new OpenApiLicense { Name = "MIT" }
            });

            c.TagActionsBy(api => new[] { api.GroupName ?? api.ActionDescriptor.RouteValues["controller"] ?? "Geral" });
            c.DocInclusionPredicate((_, __) => true);
            c.OrderActionsBy(d => $"{d.GroupName}_{d.HttpMethod}_{d.RelativePath}");

            // Define que a API usa autenticação Bearer (JWT) — aparece o botão "Authorize" no Swagger
            c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Description  = "JWT Auth. Use: Bearer {token}",
                Name         = "Authorization",
                In           = ParameterLocation.Header,
                Type         = SecuritySchemeType.ApiKey,
                Scheme       = "Bearer",
                BearerFormat = "JWT"
            });

            // Aplica o esquema de segurança globalmente para todos os endpoints
            c.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id   = "Bearer"
                        }
                    },
                    Array.Empty<string>()
                }
            });
        });

        return services;
    }

    // Configura a política de CORS — permite que qualquer origem (incluindo o app Flutter) acesse a API.
    // Em produção, seria mais restritivo (apenas domínios específicos).
    public static IServiceCollection AddCorsPolicy(this IServiceCollection services)
    {
        services.AddCors(opt =>
        {
            opt.AddPolicy("AllowAll", policy =>
            {
                policy.AllowAnyOrigin()
                      .AllowAnyMethod()
                      .AllowAnyHeader();
            });
        });
        return services;
    }
}
