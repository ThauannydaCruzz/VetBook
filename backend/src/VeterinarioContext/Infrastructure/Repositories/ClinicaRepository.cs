using Microsoft.EntityFrameworkCore;
using VetBook.SharedKernel.Common;
using VetBook.VeterinarioContext.Domain.Entities;
using VetBook.VeterinarioContext.Domain.Interfaces;
using VetBook.VeterinarioContext.Infrastructure.Data;

namespace VetBook.VeterinarioContext.Infrastructure.Repositories;

// Repositório de clínicas — implementa IClinicaRepository usando EF Core.
// Todas as operações são assíncronas e suportam CancellationToken.
public class ClinicaRepository : IClinicaRepository
{
    private readonly VeterinarioDbContext _db;
    public ClinicaRepository(VeterinarioDbContext db) => _db = db;

    // Busca por ID com FirstOrDefaultAsync — retorna null se não encontrar
    public Task<Clinica?> ObterPorIdAsync(Guid id, CancellationToken ct)
        => _db.Clinicas.FirstOrDefaultAsync(c => c.Id == id, ct);

    // Lista com paginação e filtro por nome ou endereço — ordenado por nome
    public async Task<PagedResult<Clinica>> ListarAsync(
        int page, int pageSize, string? busca, CancellationToken ct)
    {
        var query = _db.Clinicas.AsQueryable();

        // Aplica filtro de busca apenas se informado (não-nulo e não-vazio)
        if (!string.IsNullOrWhiteSpace(busca))
            query = query.Where(c => c.Nome.Contains(busca) || c.Endereco.Contains(busca));

        query = query.OrderBy(c => c.Nome);

        // Conta o total antes de paginar para calcular TotalPages no frontend
        var total = await query.CountAsync(ct);
        var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync(ct);
        return PagedResult<Clinica>.Create(items, total, page, pageSize);
    }

    // Retorna apenas clínicas ativas ordenadas por nome — usado no agendamento
    public Task<List<Clinica>> ListarAtivasAsync(CancellationToken ct)
        => _db.Clinicas.Where(c => c.Ativo).OrderBy(c => c.Nome).ToListAsync(ct);

    // Verifica unicidade do nome — o ignorarId exclui a própria clínica da checagem
    public Task<bool> NomeExisteAsync(string nome, Guid? ignorarId, CancellationToken ct)
        => _db.Clinicas.AnyAsync(c => c.Nome == nome && (ignorarId == null || c.Id != ignorarId), ct);

    // Adiciona a clínica ao contexto do EF (persiste somente após CommitAsync)
    public async Task AdicionarAsync(Clinica clinica, CancellationToken ct)
        => await _db.Clinicas.AddAsync(clinica, ct);

    // Remove a clínica do contexto do EF (persiste somente após CommitAsync)
    public Task RemoverAsync(Clinica clinica, CancellationToken ct)
    {
        _db.Clinicas.Remove(clinica);
        return Task.CompletedTask;
    }
}
