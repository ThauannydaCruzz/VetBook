using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.API.Controllers;

// Controller responsável pelo gerenciamento de donos (tutores de animais).
// Permite listar, buscar, cadastrar, atualizar e remover donos do sistema.
// A maioria dos endpoints exige autenticação (token JWT), exceto o cadastro.
[ApiController]
[Route("api/donos")]
[Authorize]
[Produces("application/json")]
[Tags("Donos")]
public class DonosController : ControllerBase
{
    // Serviço de donos — centraliza toda a lógica de negócio relacionada a donos
    private readonly IDonoService _service;

    // Logger para registrar ações importantes como criação e remoção
    private readonly ILogger<DonosController> _logger;

    public DonosController(IDonoService service, ILogger<DonosController> logger)
    {
        _service = service;
        _logger  = logger;
    }

    // Lista todos os donos com suporte a paginação e filtros (nome, CPF, email).
    // Retorna uma lista paginada para não carregar todos os registros de uma vez.
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<PagedResult<DonoResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar([FromQuery] DonoFiltro filtro, CancellationToken ct)
    {
        var result = await _service.ListarAsync(filtro, ct);
        return Ok(ApiResponse<PagedResult<DonoResponse>>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Busca um dono específico pelo ID (GUID).
    // Retorna 404 se o dono não for encontrado.
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(ApiResponse<DonoResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(Guid id, CancellationToken ct)
    {
        var result = await _service.ObterPorIdAsync(id, ct);
        return Ok(ApiResponse<DonoResponse>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Cadastra um novo dono no sistema.
    // Este endpoint é público (AllowAnonymous) — qualquer pessoa pode se cadastrar sem estar logada.
    // É aqui que o app mobile chama quando um novo usuário cria sua conta.
    [HttpPost]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<DonoResponse>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar([FromBody] CreateDonoRequest request, CancellationToken ct)
    {
        var result = await _service.CriarAsync(request, ct);
        _logger.LogInformation("Dono criado: {Id} - {Nome}", result.Id, result.Nome);
        return CreatedAtAction(nameof(ObterPorId), new { id = result.Id },
            ApiResponse<DonoResponse>.Ok(result, "Dono cadastrado com sucesso."));
    }

    // Atualiza os dados de um dono existente (nome, email, telefone, endereço).
    // O CPF não pode ser alterado após o cadastro.
    [HttpPut("{id:guid}")]
    [ProducesResponseType(typeof(ApiResponse<DonoResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Atualizar(Guid id, [FromBody] UpdateDonoRequest request, CancellationToken ct)
    {
        var result = await _service.AtualizarAsync(id, request, ct);
        return Ok(ApiResponse<DonoResponse>.Ok(result, "Dono atualizado com sucesso."));
    }

    // Remove um dono do sistema pelo ID.
    // Retorna 400 se o dono tiver pets com consultas futuras pendentes.
    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Remover(Guid id, CancellationToken ct)
    {
        await _service.RemoverAsync(id, ct);
        _logger.LogInformation("Dono removido: {Id}", id);
        return NoContent();
    }
}
