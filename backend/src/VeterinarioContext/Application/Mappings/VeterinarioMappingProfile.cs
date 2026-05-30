using AutoMapper;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Domain.Entities;

namespace VetBook.VeterinarioContext.Application.Mappings;

// Perfil AutoMapper para a entidade Veterinario.
// Define o mapeamento de Veterinario para VeterinarioResponse.
public class VeterinarioMappingProfile : Profile
{
    public VeterinarioMappingProfile()
    {
        CreateMap<Veterinario, VeterinarioResponse>()
            // Email é um Value Object — extrai o valor string normalizado (lowercase)
            .ForMember(d => d.Email, o => o.MapFrom(s => s.EmailValor))
            // ClinicaId vem diretamente da entidade (chave estrangeira)
            .ForMember(d => d.ClinicaId, o => o.MapFrom(s => s.ClinicaId))
            // ClinicaNome vem da navegação — null se veterinário não tiver clínica vinculada
            .ForMember(d => d.ClinicaNome, o => o.MapFrom(s => s.Clinica != null ? s.Clinica.Nome : null));
    }
}
