using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Domain.Entities;

namespace VetBook.CadastroContext.Application.Mappings;

// Perfil AutoMapper para o contexto de Cadastro.
// Define como as entidades de domínio (Dono, Pet) são convertidas para DTOs de resposta.
public class CadastroMappingProfile : Profile
{
    public CadastroMappingProfile()
    {
        CreateMap<Dono, DonoResponse>()
            // CPF é um Value Object — extrai o valor string (só dígitos)
            .ForMember(d => d.Cpf, o => o.MapFrom(s => s.CpfValor))
            // Email é um Value Object — extrai o valor string normalizado
            .ForMember(d => d.Email, o => o.MapFrom(s => s.EmailValor))
            // Mapeia a coleção de pets para resumos (PetResumoResponse)
            .ForMember(d => d.Pets, o => o.MapFrom(s => s.Pets));

        // Mapeamento simples de Pet para resumo (sem dados do dono)
        CreateMap<Pet, PetResumoResponse>();

        CreateMap<Pet, PetResponse>()
            // Converte o enum SexoPet para string ("Macho" / "Femea")
            .ForMember(d => d.Sexo, o => o.MapFrom(s => s.Sexo.ToString()))
            // NomeDono vem da navegação — pode ser null se não carregado
            .ForMember(d => d.NomeDono, o => o.MapFrom(s => s.Dono != null ? s.Dono.Nome : null));
    }
}
