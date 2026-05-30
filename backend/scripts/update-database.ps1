# Script para aplicar as migrations de cada contexto
# Execute a partir da raiz do projeto

Write-Host "Aplicando migrations do CadastroContext..." -ForegroundColor Cyan
dotnet ef database update `
    --project src/CadastroContext/Infrastructure `
    --startup-project src/API `
    --context CadastroDbContext

Write-Host "Aplicando migrations do VeterinarioContext..." -ForegroundColor Cyan
dotnet ef database update `
    --project src/VeterinarioContext/Infrastructure `
    --startup-project src/API `
    --context VeterinarioDbContext

Write-Host "Aplicando migrations do AgendamentoContext..." -ForegroundColor Cyan
dotnet ef database update `
    --project src/AgendamentoContext/Infrastructure `
    --startup-project src/API `
    --context AgendamentoDbContext

Write-Host "Banco de dados atualizado com sucesso!" -ForegroundColor Green
