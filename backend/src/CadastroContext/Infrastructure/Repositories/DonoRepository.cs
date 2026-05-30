using Microsoft.EntityFrameworkCore;
using VetBook.CadastroContext.Domain.Entities;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.CadastroContext.Infrastructure.Data;
using VetBook.SharedKernel.Common;

namespace VetBook.CadastroContext.Infrastructure.Repositories;

/* Repositório de Donos — responsável por toda a comunicação com o banco de dados
 * para a entidade Dono. Implementa a interface IDonoRepository, que define o contrato.
 * Usa o Entity Framework Core (EF) para executar as queries no PostgreSQL do Supabase. */
public class DonoRepository : IDonoRepository
{
    // Contexto do banco — dá acesso às tabelas do módulo de cadastro
    private readonly CadastroDbContext _context;

    public DonoRepository(CadastroDbContext context) => _context = context;

    // Busca um dono pelo ID — retorna null se não encontrar
    public async Task<Dono?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => await _context.Donos.FirstOrDefaultAsync(d => d.Id == id, ct);

    // Busca um dono pelo ID já carregando os pets dele (eager loading com Include)
    public async Task<Dono?> ObterComPetsAsync(Guid id, CancellationToken ct = default)
        => await _context.Donos.Include(d => d.Pets)
            .FirstOrDefaultAsync(d => d.Id == id, ct);

    // Busca um dono pelo CPF — remove a pontuação antes de comparar no banco
    public async Task<Dono?> ObterPorCpfAsync(string cpf, CancellationToken ct = default)
    {
        var cleaned = new string(cpf.Where(char.IsDigit).ToArray());
        return await _context.Donos.FirstOrDefaultAsync(d => d.CpfValor == cleaned, ct);
    }

    // Retorna todos os donos sem paginação — usado internamente
    public async Task<IEnumerable<Dono>> ObterTodosAsync(CancellationToken ct = default)
        => await _context.Donos.ToListAsync(ct);

    // Verifica se o CPF já está cadastrado no banco — evita duplicatas.
    // O parâmetro ignorarId permite excluir um dono específico da busca (útil na atualização).
    public async Task<bool> CpfExisteAsync(string cpf, Guid? ignorarId = null, CancellationToken ct = default)
    {
        var cleaned = new string(cpf.Where(char.IsDigit).ToArray());
        var query = _context.Donos.Where(d => d.CpfValor == cleaned);
        if (ignorarId.HasValue) query = query.Where(d => d.Id != ignorarId.Value);
        return await query.AnyAsync(ct);
    }

    // Lista donos com suporte a filtros (nome, CPF, email), ordenação e paginação.
    // Retorna um PagedResult contendo os itens da página e o total geral.
    public async Task<PagedResult<Dono>> ListarAsync(DonoFiltro filtro, CancellationToken ct = default)
    {
        // Começa com todos os donos incluindo seus pets
        var query = _context.Donos.Include(d => d.Pets).AsQueryable();

        // Aplica os filtros opcionais — só filtra se o campo foi informado
        if (!string.IsNullOrWhiteSpace(filtro.Nome))
            query = query.Where(d => d.Nome.Contains(filtro.Nome));
        if (!string.IsNullOrWhiteSpace(filtro.Cpf))
        {
            var cleaned = new string(filtro.Cpf.Where(char.IsDigit).ToArray());
            query = query.Where(d => d.CpfValor.Contains(cleaned));
        }
        if (!string.IsNullOrWhiteSpace(filtro.Email))
            query = query.Where(d => d.EmailValor.Contains(filtro.Email.ToLower()));

        // Conta o total antes de paginar (para a UI saber quantas páginas existem)
        var total = await query.CountAsync(ct);

        // Aplica a ordenação conforme o campo solicitado
        query = filtro.OrderBy?.ToLower() switch
        {
            "nome" => filtro.OrderDescending ? query.OrderByDescending(d => d.Nome) : query.OrderBy(d => d.Nome),
            "datacadastro" => filtro.OrderDescending ? query.OrderByDescending(d => d.DataCadastro) : query.OrderBy(d => d.DataCadastro),
            _ => query.OrderBy(d => d.Nome)
        };

        // Aplica paginação: pula as páginas anteriores e pega apenas a quantidade da página atual
        var items = await query
            .Skip((filtro.Page - 1) * filtro.PageSize)
            .Take(filtro.PageSize)
            .ToListAsync(ct);

        return PagedResult<Dono>.Create(items, total, filtro.Page, filtro.PageSize);
    }

    // Adiciona um novo dono ao contexto — ainda não salva no banco (o commit é feito pelo UnitOfWork)
    public async Task AdicionarAsync(Dono entity, CancellationToken ct = default)
        => await _context.Donos.AddAsync(entity, ct);

    // Marca a entidade como modificada — o EF vai gerar o UPDATE no próximo commit
    public void Atualizar(Dono entity) => _context.Donos.Update(entity);

    // Marca a entidade para remoção — o EF vai gerar o DELETE no próximo commit
    public void Remover(Dono entity) => _context.Donos.Remove(entity);
}
