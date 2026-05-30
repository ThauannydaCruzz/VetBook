using Microsoft.EntityFrameworkCore;
using VetBook.CadastroContext.Domain.Entities;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.CadastroContext.Infrastructure.Data;
using VetBook.SharedKernel.Common;

namespace VetBook.CadastroContext.Infrastructure.Repositories;

/* Repositório de Pets — responsável por toda a comunicação com o banco de dados
 * para a entidade Pet. Inclui uma verificação especial via SQL puro para checar
 * consultas futuras (necessário porque Consultas ficam em outro DbContext). */
public class PetRepository : IPetRepository
{
    // Contexto do banco do módulo de cadastro
    private readonly CadastroDbContext _context;

    public PetRepository(CadastroDbContext context) => _context = context;

    // Busca um pet pelo ID, já carregando o dono associado (para exibir o nome do tutor)
    public async Task<Pet?> ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => await _context.Pets.Include(p => p.Dono)
            .FirstOrDefaultAsync(p => p.Id == id, ct);

    // Retorna todos os pets com seus donos — sem paginação
    public async Task<IEnumerable<Pet>> ObterTodosAsync(CancellationToken ct = default)
        => await _context.Pets.Include(p => p.Dono).ToListAsync(ct);

    // Retorna todos os pets de um dono específico, ordenados por nome
    public async Task<IEnumerable<Pet>> ObterPorDonoAsync(Guid donoId, CancellationToken ct = default)
        => await _context.Pets.Include(p => p.Dono)
            .Where(p => p.DonoId == donoId)
            .OrderBy(p => p.Nome)
            .ToListAsync(ct);

    /* Verifica se um pet tem consultas futuras agendadas ou confirmadas.
     * Usamos SQL puro aqui porque a tabela Consultas pertence a outro DbContext (AgendamentoContext).
     * Fazer uma query LINQ cruzando contextos causaria erro, então acessamos diretamente via DbConnection. */
    public async Task<bool> PossuiConsultasFuturasAsync(Guid petId, CancellationToken ct = default)
    {
        var agora = DateTime.UtcNow.ToString("yyyy-MM-dd HH:mm:ss");
        var petIdStr = petId.ToString();

        using var cmd = _context.Database.GetDbConnection().CreateCommand();
        cmd.CommandText = """
            SELECT COUNT(1) FROM Consultas
            WHERE PetId = @petId
              AND DataConsulta > @agora
              AND StatusConsulta NOT IN ('Cancelada','Finalizada')
            """;

        var pPet = cmd.CreateParameter();
        pPet.ParameterName = "@petId";
        pPet.Value = petIdStr;
        cmd.Parameters.Add(pPet);

        var pAgora = cmd.CreateParameter();
        pAgora.ParameterName = "@agora";
        pAgora.Value = agora;
        cmd.Parameters.Add(pAgora);

        // Garante que a conexão está aberta antes de executar o comando
        if (cmd.Connection!.State != System.Data.ConnectionState.Open)
            await cmd.Connection.OpenAsync(ct);

        var result = await cmd.ExecuteScalarAsync(ct);
        return Convert.ToInt32(result) > 0;
    }

    // Lista pets com filtros (nome, espécie, raça, donoId) e paginação
    public async Task<PagedResult<Pet>> ListarAsync(PetFiltro filtro, CancellationToken ct = default)
    {
        var query = _context.Pets.Include(p => p.Dono).AsQueryable();

        // Aplica os filtros opcionais
        if (!string.IsNullOrWhiteSpace(filtro.Nome))
            query = query.Where(p => p.Nome.Contains(filtro.Nome));

        if (!string.IsNullOrWhiteSpace(filtro.Especie))
            query = query.Where(p => p.Especie.Contains(filtro.Especie));

        if (!string.IsNullOrWhiteSpace(filtro.Raca))
            query = query.Where(p => p.Raca.Contains(filtro.Raca));

        if (filtro.DonoId.HasValue)
            query = query.Where(p => p.DonoId == filtro.DonoId.Value);

        var total = await query.CountAsync(ct);

        // Aplica ordenação conforme o campo solicitado
        query = filtro.OrderBy?.ToLower() switch
        {
            "nome" => filtro.OrderDescending ? query.OrderByDescending(p => p.Nome) : query.OrderBy(p => p.Nome),
            "especie" => filtro.OrderDescending ? query.OrderByDescending(p => p.Especie) : query.OrderBy(p => p.Especie),
            "datacadastro" => filtro.OrderDescending ? query.OrderByDescending(p => p.DataCadastro) : query.OrderBy(p => p.DataCadastro),
            _ => query.OrderBy(p => p.Nome)
        };

        var items = await query
            .Skip((filtro.Page - 1) * filtro.PageSize)
            .Take(filtro.PageSize)
            .ToListAsync(ct);

        return PagedResult<Pet>.Create(items, total, filtro.Page, filtro.PageSize);
    }

    // Adiciona um novo pet ao contexto (não salva ainda — commit feito pelo UnitOfWork)
    public async Task AdicionarAsync(Pet entity, CancellationToken ct = default)
        => await _context.Pets.AddAsync(entity, ct);

    // Marca o pet como modificado para o EF gerar o UPDATE
    public void Atualizar(Pet entity) => _context.Pets.Update(entity);

    // Marca o pet para remoção — o EF gera o DELETE no próximo commit
    public void Remover(Pet entity) => _context.Pets.Remove(entity);
}
