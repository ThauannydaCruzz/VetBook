using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.CadastroContext.Application.Interfaces;

// Interface de serviço de pets — fachada para todos os Use Cases de pet.
// Consumida pelos Controllers da API.
public interface IPetService
{
    // Cria um pet validando que o dono existe no sistema
    Task<PetResponse> CriarAsync(CreatePetRequest request, CancellationToken ct = default);

    // Atualiza os dados do pet (exceto DonoId)
    Task<PetResponse> AtualizarAsync(Guid id, UpdatePetRequest request, CancellationToken ct = default);

    // Remove um pet — bloqueia se houver consultas futuras agendadas
    Task RemoverAsync(Guid id, CancellationToken ct = default);

    // Busca um pet pelo ID
    Task<PetResponse> ObterPorIdAsync(Guid id, CancellationToken ct = default);

    // Lista pets com paginação e filtros (nome, espécie, raça, donoId)
    Task<PagedResult<PetResponse>> ListarAsync(PetFiltro filtro, CancellationToken ct = default);

    // Retorna todos os pets de um dono específico (sem paginação)
    Task<IEnumerable<PetResponse>> ObterPorDonoAsync(Guid donoId, CancellationToken ct = default);
}
