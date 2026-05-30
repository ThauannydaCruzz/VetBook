using Microsoft.EntityFrameworkCore;
using VetBook.AgendamentoContext.Domain.Entities;
using VetBook.AgendamentoContext.Domain.Enums;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.AgendamentoContext.Infrastructure.Data;
using VetBook.CadastroContext.Infrastructure.Data;
using VetBook.SharedKernel.Common;

namespace VetBook.AgendamentoContext.Infrastructure.Repositories;

/* Repositório de Consultas — responsável por toda a comunicação com o banco
 * para a entidade Consulta. Recebe dois contextos:
 * - AgendamentoDbContext: tabela de consultas (principal)
 * - CadastroDbContext: tabela de pets (necessário para filtrar consultas por DonoId) */
public class ConsultaRepository : IConsultaRepository
{
    private readonly AgendamentoDbContext _context;

    // Usado apenas para filtrar pets pelo DonoId ao listar consultas de um dono
    private readonly CadastroDbContext _cadastroContext;

    // Janela de tempo para verificar conflito de horário: ±59 minutos = slot de 1 hora
    private static readonly TimeSpan SlotDuracao = TimeSpan.FromMinutes(60);

    public ConsultaRepository(AgendamentoDbContext context, CadastroDbContext cadastroContext)
    {
        _context = context;
        _cadastroContext = cadastroContext;
    }

    // Busca uma consulta pelo ID — retorna null se não encontrar
    public async Task<Consulta?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => await _context.Consultas.FirstOrDefaultAsync(c => c.Id == id, ct);

    // Retorna todas as consultas, da mais recente para a mais antiga
    public async Task<IEnumerable<Consulta>> ObterTodosAsync(CancellationToken ct = default)
        => await _context.Consultas.OrderByDescending(c => c.DataConsulta).ToListAsync(ct);

    /* Verifica se o veterinário já tem uma consulta no mesmo horário (±59 minutos).
     * Isso evita que o mesmo veterinário seja agendado duas vezes no mesmo período.
     * O parâmetro ignorarId é usado no reagendamento para ignorar a própria consulta. */
    public async Task<bool> ExisteConflitoPorVeterinarioAsync(Guid veterinarioId, DateTime dataConsulta,
        Guid? ignorarId = null, CancellationToken ct = default)
    {
        var inicio = dataConsulta.AddMinutes(-59);
        var fim = dataConsulta.AddMinutes(59);
        var query = _context.Consultas.Where(c =>
            c.VeterinarioId == veterinarioId &&
            c.DataConsulta >= inicio && c.DataConsulta <= fim &&
            c.StatusConsulta != StatusConsulta.Cancelada); // Consultas canceladas não bloqueiam horário

        if (ignorarId.HasValue) query = query.Where(c => c.Id != ignorarId.Value);
        return await query.AnyAsync(ct);
    }

    /* Verifica se o pet já tem uma consulta no mesmo horário (±59 minutos).
     * Um pet não pode ter dois atendimentos simultâneos. */
    public async Task<bool> ExisteConflitoPorPetAsync(Guid petId, DateTime dataConsulta,
        Guid? ignorarId = null, CancellationToken ct = default)
    {
        var inicio = dataConsulta.AddMinutes(-59);
        var fim = dataConsulta.AddMinutes(59);
        var query = _context.Consultas.Where(c =>
            c.PetId == petId &&
            c.DataConsulta >= inicio && c.DataConsulta <= fim &&
            c.StatusConsulta != StatusConsulta.Cancelada);

        if (ignorarId.HasValue) query = query.Where(c => c.Id != ignorarId.Value);
        return await query.AnyAsync(ct);
    }

    // Retorna todas as consultas de um pet específico, da mais recente para a mais antiga
    public async Task<IEnumerable<Consulta>> ObterPorPetAsync(Guid petId, CancellationToken ct = default)
        => await _context.Consultas
            .Where(c => c.PetId == petId)
            .OrderByDescending(c => c.DataConsulta)
            .ToListAsync(ct);

    // Retorna todas as consultas de um veterinário específico
    public async Task<IEnumerable<Consulta>> ObterPorVeterinarioAsync(Guid veterinarioId, CancellationToken ct = default)
        => await _context.Consultas
            .Where(c => c.VeterinarioId == veterinarioId)
            .OrderByDescending(c => c.DataConsulta)
            .ToListAsync(ct);

    // Lista consultas com múltiplos filtros e paginação
    public async Task<PagedResult<Consulta>> ListarAsync(ConsultaFiltro filtro, CancellationToken ct = default)
    {
        var query = _context.Consultas.AsQueryable();

        // Filtro por pet específico
        if (filtro.PetId.HasValue)
            query = query.Where(c => c.PetId == filtro.PetId.Value);

        // Filtro por veterinário específico
        if (filtro.VeterinarioId.HasValue)
            query = query.Where(c => c.VeterinarioId == filtro.VeterinarioId.Value);

        /* Filtro por DonoId — como a tabela de pets está em outro contexto,
         * primeiro buscamos os IDs dos pets do dono, depois filtramos as consultas */
        if (filtro.DonoId.HasValue)
        {
            var petIds = await _cadastroContext.Pets
                .Where(p => p.DonoId == filtro.DonoId.Value)
                .Select(p => p.Id)
                .ToListAsync(ct);
            query = query.Where(c => petIds.Contains(c.PetId));
        }

        // Filtro por status (Agendada, Confirmada, Finalizada, Cancelada)
        if (filtro.Status.HasValue)
            query = query.Where(c => c.StatusConsulta == filtro.Status.Value);

        // Filtro por período (data início e data fim)
        if (filtro.DataInicio.HasValue)
            query = query.Where(c => c.DataConsulta >= filtro.DataInicio.Value);

        if (filtro.DataFim.HasValue)
            query = query.Where(c => c.DataConsulta <= filtro.DataFim.Value);

        var total = await query.CountAsync(ct);

        // Ordenação — padrão é da consulta mais recente para a mais antiga
        query = filtro.OrderBy?.ToLower() switch
        {
            "dataconsulta" => filtro.OrderDescending
                ? query.OrderByDescending(c => c.DataConsulta)
                : query.OrderBy(c => c.DataConsulta),
            "status" => filtro.OrderDescending
                ? query.OrderByDescending(c => c.StatusConsulta)
                : query.OrderBy(c => c.StatusConsulta),
            _ => query.OrderByDescending(c => c.DataConsulta)
        };

        var items = await query
            .Skip((filtro.Page - 1) * filtro.PageSize)
            .Take(filtro.PageSize)
            .ToListAsync(ct);

        return PagedResult<Consulta>.Create(items, total, filtro.Page, filtro.PageSize);
    }

    // Adiciona uma nova consulta ao contexto (commit feito pelo UnitOfWork)
    public async Task AdicionarAsync(Consulta entity, CancellationToken ct = default)
        => await _context.Consultas.AddAsync(entity, ct);

    // Marca a consulta como modificada para o EF gerar o UPDATE
    public void Atualizar(Consulta entity) => _context.Consultas.Update(entity);

    // Marca a consulta para remoção
    public void Remover(Consulta entity) => _context.Consultas.Remove(entity);
}
