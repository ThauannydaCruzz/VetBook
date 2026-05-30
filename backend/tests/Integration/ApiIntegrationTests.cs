using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using VetBook.AgendamentoContext.Infrastructure.Data;
using VetBook.API.Authentication;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Infrastructure.Data;
using VetBook.SharedKernel.Common;
using VetBook.VeterinarioContext.Infrastructure.Data;

namespace VetBook.Tests.Integration;

public class ApiIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public ApiIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory.WithWebHostBuilder(builder =>
        {
            builder.ConfigureServices(services =>
            {
                // Substituir DbContexts por InMemory
                var descriptors = services.Where(d =>
                    d.ServiceType == typeof(DbContextOptions<CadastroDbContext>) ||
                    d.ServiceType == typeof(DbContextOptions<VeterinarioDbContext>) ||
                    d.ServiceType == typeof(DbContextOptions<AgendamentoDbContext>)).ToList();

                foreach (var d in descriptors) services.Remove(d);

                services.AddDbContext<CadastroDbContext>(o => o.UseInMemoryDatabase("CadastroTest"));
                services.AddDbContext<VeterinarioDbContext>(o => o.UseInMemoryDatabase("VeterinarioTest"));
                services.AddDbContext<AgendamentoDbContext>(o => o.UseInMemoryDatabase("AgendamentoTest"));
            });
        });

        _client = _factory.CreateClient();
    }

    private async Task<string> ObterTokenAsync()
    {
        var response = await _client.PostAsJsonAsync("/api/auth/login",
            new LoginRequest("admin", "Admin@123!"));
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<ApiResponse<LoginResponse>>();
        return result!.Data!.Token;
    }

    [Fact]
    public async Task HealthCheck_DeveRetornarOk()
    {
        var response = await _client.GetAsync("/health");
        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }

    [Fact]
    public async Task Login_ComCredenciaisValidas_DeveRetornarToken()
    {
        var response = await _client.PostAsJsonAsync("/api/auth/login",
            new LoginRequest("admin", "Admin@123!"));

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var result = await response.Content.ReadFromJsonAsync<ApiResponse<LoginResponse>>();
        result!.Success.Should().BeTrue();
        result.Data!.Token.Should().NotBeEmpty();
    }

    [Fact]
    public async Task Login_ComCredenciaisInvalidas_DeveRetornar401()
    {
        var response = await _client.PostAsJsonAsync("/api/auth/login",
            new LoginRequest("admin", "senhaerrada"));

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Donos_SemToken_DeveRetornar401()
    {
        var response = await _client.GetAsync("/api/donos");
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Donos_CriarEListar_DeveRetornarDadosCorretamente()
    {
        var token = await ObterTokenAsync();
        _client.DefaultRequestHeaders.Authorization =
            new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

        // Criar dono
        var request = new CreateDonoRequest(
            "Maria Silva", "529.982.247-25", "maria@email.com", "11987654321", "Rua das Flores, 100");

        var createResponse = await _client.PostAsJsonAsync("/api/donos", request);
        createResponse.StatusCode.Should().Be(HttpStatusCode.Created);

        var created = await createResponse.Content.ReadFromJsonAsync<ApiResponse<DonoResponse>>();
        created!.Success.Should().BeTrue();
        created.Data!.Nome.Should().Be("Maria Silva");

        // Listar
        var listResponse = await _client.GetAsync("/api/donos");
        listResponse.StatusCode.Should().Be(HttpStatusCode.OK);

        var list = await listResponse.Content.ReadFromJsonAsync<ApiResponse<PagedResult<DonoResponse>>>();
        list!.Data!.Items.Should().ContainSingle(d => d.Nome == "Maria Silva");
    }

    [Fact]
    public async Task Donos_CriarComCpfInvalido_DeveRetornar400()
    {
        var token = await ObterTokenAsync();
        _client.DefaultRequestHeaders.Authorization =
            new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);

        var request = new CreateDonoRequest(
            "Maria Silva", "111.111.111-11", "maria@email.com", "11987654321", "Rua A");

        var response = await _client.PostAsJsonAsync("/api/donos", request);
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }
}
