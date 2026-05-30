using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.API.Controllers;

// Controller responsável pelo gerenciamento de pets (animais dos donos).
// Permite cadastrar, listar, buscar, atualizar e remover pets.
// Todos os endpoints exigem autenticação com token JWT.
[ApiController]
[Route("api/pets")]
[Authorize]
[Produces("application/json")]
[Tags("Pets")]
public class PetsController : ControllerBase
{
    // Serviço de pets — centraliza toda a lógica de negócio relacionada a animais
    private readonly IPetService _service;

    // Logger para registrar criação e remoção de pets
    private readonly ILogger<PetsController> _logger;

    public PetsController(IPetService service, ILogger<PetsController> logger)
    {
        _service = service;
        _logger = logger;
    }

    // Lista todos os pets com suporte a filtros (nome, espécie, raça, donoId) e paginação.
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<PagedResult<PetResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar([FromQuery] PetFiltro filtro, CancellationToken ct)
    {
        var result = await _service.ListarAsync(filtro, ct);
        return Ok(ApiResponse<PagedResult<PetResponse>>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Lista todos os pets que pertencem a um dono específico.
    // Muito útil no app para mostrar os animais do usuário logado.
    [HttpGet("dono/{donoId:guid}")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<PetResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterPorDono(Guid donoId, CancellationToken ct)
    {
        var result = await _service.ObterPorDonoAsync(donoId, ct);
        return Ok(ApiResponse<IEnumerable<PetResponse>>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Busca um pet específico pelo ID (GUID).
    // Retorna 404 se o pet não for encontrado.
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(ApiResponse<PetResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(Guid id, CancellationToken ct)
    {
        var result = await _service.ObterPorIdAsync(id, ct);
        return Ok(ApiResponse<PetResponse>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Cadastra um novo pet no sistema vinculado a um dono existente.
    // O donoId deve referenciar um dono já cadastrado no banco.
    // Sexo: 0 = Macho, 1 = Fêmea
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<PetResponse>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar([FromBody] CreatePetRequest request, CancellationToken ct)
    {
        var result = await _service.CriarAsync(request, ct);
        _logger.LogInformation("Pet criado: {Id} - {Nome}", result.Id, result.Nome);
        return CreatedAtAction(nameof(ObterPorId), new { id = result.Id },
            ApiResponse<PetResponse>.Ok(result, "Pet cadastrado com sucesso."));
    }

    // Atualiza os dados de um pet existente (nome, espécie, raça, idade, peso, etc.).
    [HttpPut("{id:guid}")]
    [ProducesResponseType(typeof(ApiResponse<PetResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Atualizar(Guid id, [FromBody] UpdatePetRequest request, CancellationToken ct)
    {
        var result = await _service.AtualizarAsync(id, request, ct);
        return Ok(ApiResponse<PetResponse>.Ok(result, "Pet atualizado com sucesso."));
    }

    // Remove um pet do sistema.
    // Não é permitido remover pets que tenham consultas futuras agendadas ou confirmadas.
    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Remover(Guid id, CancellationToken ct)
    {
        await _service.RemoverAsync(id, ct);
        _logger.LogInformation("Pet removido: {Id}", id);
        return NoContent();
    }
}
