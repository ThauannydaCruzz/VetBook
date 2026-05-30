namespace VetBook.API.Authentication;

// Configurações do JWT lidas do appsettings.json via seção "JwtSettings".
// São injetadas no sistema de DI e usadas para gerar e validar tokens de acesso.
public class JwtSettings
{
    // Chave secreta usada para assinar o token — deve ser longa e mantida em segredo
    public string SecretKey { get; set; } = default!;

    // Identificador do emissor do token (ex: "VetBook.API")
    public string Issuer { get; set; } = default!;

    // Público-alvo do token — quem pode consumir (ex: "VetBook.Client")
    public string Audience { get; set; } = default!;

    // Tempo de validade do token em minutos — padrão 60 minutos
    public int ExpirationMinutes { get; set; } = 60;
}
