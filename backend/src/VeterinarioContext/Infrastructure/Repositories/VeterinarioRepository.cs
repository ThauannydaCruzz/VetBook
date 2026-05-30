using Microsoft.EntityFrameworkCore;
using VetBook.SharedKernel.Common;
using VetBook.VeterinarioContext.Domain.Entities;
using VetBook.VeterinarioContext.Domain.Interfaces;
using VetBook.VeterinarioContext.Infrastructure.Data;

namespace VetBook.VeterinarioContext.Infrastructure.Repositories;

/* Repositório de Veterinários — responsável por toda a comunicação com o banco
 * para a entidade Veterinario. Usa o VeterinarioDbContext que inclui também a tabela de Clínicas. */
public class VeterinarioRepository : IVeterinarioRepository
{
    // Contexto do módulo de veterinários — acessa tabelas Veterinarios e Clinicas
    private readonly VeterinarioDbContext _context;

    public VeterinarioRepository(VeterinarioDbContext context) => _context = context;

    // Busca um veterinário pelo ID, carregando também a clínica associada
    public async Task<Veterinario?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => await _context.Veterinarios
            .Include(v => v.Clinica)
            .FirstOrDefaultAsync(v => v.Id == id, ct);

    // Retorna todos os veterinários ordenados por nome, com suas clínicas
    public async Task<IEnumerable<Veterinario>> ObterTodosAsync(CancellationToken ct = default)
        => await _context.Veterinarios
            .Include(v => v.Clinica)
            .OrderBy(v => v.Nome).ToListAsync(ct);

    // Retorna apenas veterinários ativos — usado na seleção de veterinário durante o agendamento
    public async Task<IEnumerable<Veterinario>> ListarAtivosAsync(CancellationToken ct = default)
        => await _context.Veterinarios
            .Include(v => v.Clinica)
            .Where(v => v.Ativo)
            .OrderBy(v => v.Nome).ToListAsync(ct);

    // Verifica se o CRMV já está cadastrado — evita duplicatas.
    // O ignorarId é usado na atualização para não conflitar com o próprio registro.
    public async Task<bool> CrmvExisteAsync(string crmv, Guid? ignorarId = null, CancellationToken ct = default)
    {
        var cleaned = crmv.ToUpper().Trim();
        var query = _context.Veterinarios.Where(v => v.Crmv == cleaned);
        if (ignorarId.HasValue) query = query.Where(v => v.Id != ignorarId.Value);
        return await query.AnyAsync(ct);
    }

    // Lista veterinários com filtros (nome, CRMV, especialidade, ativo) e paginação
    public async Task<PagedResult<Veterinario>> ListarAsync(VeterinarioFiltro filtro, CancellationToken ct = default)
    {
        var query = _context.Veterinarios
            .Include(v => v.Clinica)
            .AsQueryable();

        // Aplica filtros opcionais
        if (!string.IsNullOrWhiteSpace(filtro.Nome))
            query = query.Where(v => v.Nome.Contains(filtro.Nome));
        if (!string.IsNullOrWhiteSpace(filtro.Crmv))
            query = query.Where(v => v.Crmv.Contains(filtro.Crmv.ToUpper()));
        if (!string.IsNullOrWhiteSpace(filtro.Especialidade))
            query = query.Where(v => v.Especialidade.Contains(filtro.Especialidade));
        if (filtro.Ativo.HasValue)
            query = query.Where(v => v.Ativo == filtro.Ativo.Value);

        var total = await query.CountAsync(ct);

        // Ordenação — padrão é por nome
        query = filtro.OrderBy?.ToLower() switch
        {
            "especialidade" => filtro.OrderDescending
                ? query.OrderByDescending(v => v.Especialidade) : query.OrderBy(v => v.Especialidade),
            "datacadastro" => filtro.OrderDescending
                ? query.OrderByDescending(v => v.DataCadastro) : query.OrderBy(v => v.DataCadastro),
            _ => query.OrderBy(v => v.Nome)
        };

        var items = await query
            .Skip((filtro.Page - 1) * filtro.PageSize)
            .Take(filtro.PageSize)
            .ToListAsync(ct);

        return PagedResult<Veterinario>.Create(items, total, filtro.Page, filtro.PageSize);
    }

    // Adiciona um novo veterinário ao contexto (commit feito pelo UnitOfWork)
    public async Task AdicionarAsync(Veterinario entity, CancellationToken ct = default)
        => await _context.Veterinarios.AddAsync(entity, ct);

    // Marca o veterinário como modificado para o EF gerar o UPDATE
    public void Atualizar(Veterinario entity) => _context.Veterinarios.Update(entity);

    // Marca o veterinário para remoção
    public void Remover(Veterinario entity)   => _context.Veterinarios.Remove(entity);
}
