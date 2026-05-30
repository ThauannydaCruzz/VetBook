# Script para criar as migrations de cada contexto
# Execute a partir da raiz do projeto

Write-Host "Criando migrations do CadastroContext..." -ForegroundColor Cyan
dotnet ef migrations add InitialCreate `
    --project src/CadastroContext/Infrastructure `
    --startup-project src/API `
    --context CadastroDbContext `
    --output-dir Migrations

Write-Host "Criando migrations do VeterinarioContext..." -ForegroundColor Cyan
dotnet ef migrations add InitialCreate `
    --project src/VeterinarioContext/Infrastructure `
    --startup-project src/API `
    --context VeterinarioDbContext `
    --output-dir Migrations

Write-Host "Criando migrations do AgendamentoContext..." -ForegroundColor Cyan
dotnet ef migrations add InitialCreate `
    --project src/AgendamentoContext/Infrastructure `
    --startup-project src/API `
    --context AgendamentoDbContext `
    --output-dir Migrations

Write-Host "Migrations criadas com sucesso!" -ForegroundColor Green
