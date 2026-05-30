namespace VetBook.SharedKernel.Common;

/* Resultado paginado genérico — retornado em todas as listagens da API.
 * Inclui os itens da página atual e metadados de paginação para o frontend
 * construir controles de navegação (próxima/anterior página). */
public class PagedResult<T>
{
    // Itens da página atual
    public IEnumerable<T> Items { get; set; } = Enumerable.Empty<T>();

    // Total de registros (todas as páginas)
    public int TotalItems { get; set; }

    // Número da página atual (começa em 1)
    public int Page { get; set; }

    // Quantidade de itens por página
    public int PageSize { get; set; }

    // Total de páginas calculado automaticamente
    public int TotalPages => (int)Math.Ceiling((double)TotalItems / PageSize);

    // Indica se existe uma página anterior
    public bool HasPreviousPage => Page > 1;

    // Indica se existe uma próxima página
    public bool HasNextPage => Page < TotalPages;

    // Factory method para criar o resultado paginado com todos os metadados
    public static PagedResult<T> Create(IEnumerable<T> items, int totalItems, int page, int pageSize)
        => new()
        {
            Items = items,
            TotalItems = totalItems,
            Page = page,
            PageSize = pageSize
        };
}

/* Classe base de filtro para queries paginadas.
 * Herdada por todos os filtros (DonoFiltro, PetFiltro, etc.)
 * para garantir paginação consistente em toda a API. */
public class PagedQuery
{
    private int _page = 1;
    private int _pageSize = 10;

    // Página mínima é 1 — valores menores são corrigidos automaticamente
    public int Page
    {
        get => _page;
        set => _page = value < 1 ? 1 : value;
    }

    // Tamanho de página entre 1 e 100 — evita consultas excessivamente grandes
    public int PageSize
    {
        get => _pageSize;
        set => _pageSize = value < 1 ? 10 : value > 100 ? 100 : value;
    }

    // Campo de ordenação (ex: "Nome", "DataCadastro")
    public string? OrderBy { get; set; }

    // Se true, ordena do maior para o menor
    public bool OrderDescending { get; set; }
}
