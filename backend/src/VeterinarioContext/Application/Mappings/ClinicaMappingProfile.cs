using AutoMapper;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Domain.Entities;

namespace VetBook.VeterinarioContext.Application.Mappings;

// Perfil AutoMapper para a entidade Clinica.
// Define como a entidade é convertida para o DTO de resposta (ClinicaResponse).
public class ClinicaMappingProfile : Profile
{
    public ClinicaMappingProfile()
    {
        // Mapeamento direto — todos os campos coincidem em nome e tipo
        CreateMap<Clinica, ClinicaResponse>();
    }
}
