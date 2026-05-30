using AutoMapper;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Domain.Entities;

namespace VetBook.AgendamentoContext.Application.Mappings;

// Perfil de mapeamento AutoMapper do contexto de Agendamento.
// Define como a entidade Consulta é convertida para ConsultaResponse.
public class AgendamentoMappingProfile : Profile
{
    public AgendamentoMappingProfile()
    {
        CreateMap<Consulta, ConsultaResponse>()
            // Converte o enum StatusConsulta para string legível (ex: "Agendada")
            .ForMember(d => d.StatusConsulta, o => o.MapFrom(s => s.StatusConsulta.ToString()))
            // NomePet e NomeVeterinario são ignorados aqui — preenchidos manualmente no Use Case
            .ForMember(d => d.NomePet, o => o.Ignore())
            .ForMember(d => d.NomeVeterinario, o => o.Ignore());
    }
}
