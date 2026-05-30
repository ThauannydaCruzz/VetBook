# 🐾 VetBook — Sistema Veterinário

Sistema completo de gestão veterinária desenvolvido com **.NET 8**, **ASP.NET Core Web API**, seguindo os princípios de **Domain-Driven Design (DDD)**, **Clean Architecture**, **SOLID** e **CQRS** quando aplicável.

---

## 📐 Arquitetura

```
VetBook/
├── src/
│   ├── SharedKernel/                    # Código compartilhado entre contextos
│   │   ├── Entities/BaseEntity.cs       # Entidade base com Id e DataCadastro
│   │   ├── ValueObjects/                # CPF, Email (Value Objects)
│   │   ├── Interfaces/                  # IRepository<T>, IUnitOfWork
│   │   ├── Common/                      # ApiResponse<T>, PagedResult<T>
│   │   └── Exceptions/                  # DomainException, NotFoundException
│   │
│   ├── CadastroContext/                 # Bounded Context: Donos e Pets
│   │   ├── Domain/                      # Entidades ricas, interfaces de repositório
│   │   ├── Application/                 # DTOs, Validators, AutoMapper, Services
│   │   └── Infrastructure/              # EF Core, Repositórios, UnitOfWork
│   │
│   ├── VeterinarioContext/              # Bounded Context: Veterinários
│   │   ├── Domain/
│   │   ├── Application/
│   │   └── Infrastructure/
│   │
│   ├── AgendamentoContext/              # Bounded Context: Consultas
│   │   ├── Domain/
│   │   ├── Application/
│   │   └── Infrastructure/
│   │
│   └── API/                             # WebAPI principal
│       ├── Controllers/                 # REST Controllers
│       ├── Authentication/              # JWT Settings e Token Service
│       ├── Extensions/                  # DI e configurações
│       └── Middlewares/                 # Tratamento global de exceções
│
├── tests/
│   ├── Unit/                            # Testes unitários de domínio
│   └── Integration/                     # Testes de integração da API
│
├── scripts/
│   ├── seed.sql                         # Dados iniciais
│   ├── create-migrations.ps1            # Script PowerShell para migrations
│   └── update-database.ps1
│
├── Dockerfile
├── docker-compose.yml
└── README.md
```

### Princípios aplicados

- **DDD**: Entidades ricas com encapsulamento e regras de negócio no domínio
- **Clean Architecture**: Dependências apontam para dentro (Domain ← Application ← Infrastructure ← API)
- **Repository Pattern + Unit of Work**: Abstração do acesso a dados
- **Value Objects**: CPF e Email com validação embutida
- **Bounded Contexts**: Cada contexto possui seu próprio DbContext, schema e UoW
- **Respostas padronizadas**: `ApiResponse<T>` em todos os endpoints
- **Paginação**: `PagedResult<T>` com filtros em todas as listagens

---

## 🚀 Início Rápido

### Pré-requisitos
- .NET 8 SDK
- SQL Server 2019+ (ou Docker)
- Docker e Docker Compose (opcional)

### Com Docker (recomendado)

```bash
# Clone o repositório
git clone <repo-url>
cd VetBook

# Subir SQL Server + API
docker-compose up -d

# Aguardar ~30s e acessar Swagger:
# http://localhost:8080
```

### Sem Docker

1. Configure a connection string em `src/API/appsettings.json`
2. Crie as migrations:
```powershell
.\scripts\create-migrations.ps1
```
3. Aplique ao banco:
```powershell
.\scripts\update-database.ps1
```
4. Execute a API:
```bash
cd src/API
dotnet run
```
5. Acesse o Swagger: `https://localhost:7xxx` (porta exibida no console)

---

## 🔐 Autenticação JWT

### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "usuario": "admin",
  "senha": "Admin@123!"
}
```

**Usuários padrão:**
| Usuário | Senha | Role |
|---|---|---|
| `admin` | `Admin@123!` | Admin |
| `veterinario` | `Vet@123!` | Veterinario |

Use o token retornado no header:
```
Authorization: Bearer {seu_token}
```

---

## 📋 Endpoints da API

### 👤 Donos (`/api/donos`)

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/api/donos` | Listar com filtros e paginação |
| `GET` | `/api/donos/{id}` | Obter por ID (com pets) |
| `POST` | `/api/donos` | Cadastrar novo dono |
| `PUT` | `/api/donos/{id}` | Atualizar dono |
| `DELETE` | `/api/donos/{id}` | Remover dono |

**Query params para listagem:** `nome`, `cpf`, `email`, `page`, `pageSize`, `orderBy`, `orderDescending`

**Exemplo - Criar Dono:**
```http
POST /api/donos
Authorization: Bearer {token}
Content-Type: application/json

{
  "nome": "Maria Silva",
  "cpf": "529.982.247-25",
  "email": "maria@email.com",
  "telefone": "11987654321",
  "endereco": "Rua das Flores, 100 - São Paulo/SP"
}
```

---

### 🐕 Pets (`/api/pets`)

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/api/pets` | Listar com filtros e paginação |
| `GET` | `/api/pets/{id}` | Obter por ID |
| `GET` | `/api/pets/dono/{donoId}` | Listar pets de um dono |
| `POST` | `/api/pets` | Cadastrar pet |
| `PUT` | `/api/pets/{id}` | Atualizar pet |
| `DELETE` | `/api/pets/{id}` | Remover pet |

**Query params:** `nome`, `especie`, `raca`, `donoId`, `page`, `pageSize`

**Exemplo - Criar Pet:**
```http
POST /api/pets
Authorization: Bearer {token}
Content-Type: application/json

{
  "nome": "Rex",
  "especie": "Cachorro",
  "raca": "Labrador",
  "idade": 3,
  "peso": 28.5,
  "sexo": 0,
  "observacoes": "Vacinado em dia",
  "donoId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
}
```

> **Sexo:** `0` = Macho, `1` = Femea

---

### 🩺 Veterinários (`/api/veterinarios`)

| Método | Rota | Descrição | Role |
|--------|------|-----------|------|
| `GET` | `/api/veterinarios` | Listar com filtros | Qualquer |
| `GET` | `/api/veterinarios/ativos` | Listar apenas ativos | Qualquer |
| `GET` | `/api/veterinarios/{id}` | Obter por ID | Qualquer |
| `POST` | `/api/veterinarios` | Cadastrar | Admin |
| `PUT` | `/api/veterinarios/{id}` | Atualizar | Admin |
| `PATCH` | `/api/veterinarios/{id}/ativar` | Ativar | Admin |
| `PATCH` | `/api/veterinarios/{id}/inativar` | Inativar | Admin |
| `DELETE` | `/api/veterinarios/{id}` | Remover | Admin |

**Exemplo - Criar Veterinário:**
```http
POST /api/veterinarios
Authorization: Bearer {token-admin}
Content-Type: application/json

{
  "nome": "Dr. Carlos Andrade",
  "crmv": "SP-12345",
  "especialidade": "Clínica Geral",
  "email": "carlos@clinica.com",
  "telefone": "11987654321"
}
```

---

### 📅 Consultas (`/api/consultas`)

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/api/consultas` | Listar com filtros e paginação |
| `GET` | `/api/consultas/{id}` | Obter por ID |
| `GET` | `/api/consultas/pet/{petId}` | Consultas de um pet |
| `GET` | `/api/consultas/veterinario/{vetId}` | Agenda do veterinário |
| `POST` | `/api/consultas` | Agendar consulta |
| `PUT` | `/api/consultas/{id}` | Reagendar consulta |
| `PATCH` | `/api/consultas/{id}/confirmar` | Confirmar |
| `PATCH` | `/api/consultas/{id}/cancelar` | Cancelar |
| `PATCH` | `/api/consultas/{id}/finalizar` | Finalizar |

**Query params:** `petId`, `veterinarioId`, `status`, `dataInicio`, `dataFim`, `page`, `pageSize`

**Exemplo - Agendar Consulta:**
```http
POST /api/consultas
Authorization: Bearer {token}
Content-Type: application/json

{
  "petId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "veterinarioId": "3fa85f64-5717-4562-b3fc-2c963f66afa7",
  "dataConsulta": "2025-02-15T10:00:00Z",
  "motivoConsulta": "Consulta de rotina anual",
  "observacoes": null
}
```

**Cancelar:**
```http
PATCH /api/consultas/{id}/cancelar
Authorization: Bearer {token}
Content-Type: application/json

{
  "motivoCancelamento": "Cliente solicitou cancelamento."
}
```

**Finalizar:**
```http
PATCH /api/consultas/{id}/finalizar
Authorization: Bearer {token}
Content-Type: application/json

{
  "observacoes": "Animal saudável. Vacinas em dia."
}
```

---

## 📦 Padrão de Resposta

Todos os endpoints retornam:

```json
{
  "success": true,
  "message": "Operação realizada com sucesso.",
  "data": { }
}
```

Em caso de erro:
```json
{
  "success": false,
  "message": "Descrição do erro.",
  "errors": ["Detalhe 1", "Detalhe 2"]
}
```

**Paginação:**
```json
{
  "success": true,
  "message": "Operação realizada com sucesso.",
  "data": {
    "items": [ ],
    "totalItems": 50,
    "page": 1,
    "pageSize": 10,
    "totalPages": 5,
    "hasPreviousPage": false,
    "hasNextPage": true
  }
}
```

---

## 📋 Status das Consultas

| Status | Valor | Transições válidas |
|--------|-------|--------------------|
| `Agendada` | 1 | → Confirmada, Cancelada |
| `Confirmada` | 2 | → Finalizada, Cancelada |
| `Cancelada` | 3 | (terminal) |
| `Finalizada` | 4 | (terminal) |

---

## ✅ Regras de Negócio

### Donos
- CPF único e validado pelo algoritmo oficial
- Não pode ser excluído se tiver pets cadastrados

### Pets
- Não pode ser cadastrado sem dono existente
- Não pode ser excluído com consultas futuras pendentes

### Veterinários
- CRMV único (ex: `SP-12345`)
- Apenas veterinários ativos podem receber agendamentos

### Consultas
- Data deve ser futura
- Veterinário não pode ter dois agendamentos no mesmo horário (±60 min)
- Pet não pode ter dois agendamentos no mesmo horário (±60 min)
- Consultas canceladas e finalizadas são estados terminais

---

## 🧪 Executar Testes

```bash
# Todos os testes
dotnet test

# Apenas unitários
dotnet test tests/Unit

# Apenas integração
dotnet test tests/Integration

# Com cobertura
dotnet test --collect:"XPlat Code Coverage"
```

---

## 🗃️ Banco de Dados

O sistema usa **schemas separados** por Bounded Context:

| Schema | Tabelas |
|--------|---------|
| `Cadastro` | `Donos`, `Pets` |
| `Veterinario` | `Veterinarios` |
| `Agendamento` | `Consultas` |

---

## 🔧 Tecnologias

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| .NET | 8.0 | Plataforma |
| ASP.NET Core | 8.0 | Web API |
| Entity Framework Core | 8.0 | ORM |
| SQL Server | 2022 | Banco de dados |
| AutoMapper | 13.x | Mapeamento |
| FluentValidation | 11.x | Validação |
| Serilog | 8.x | Logs estruturados |
| JWT Bearer | 8.0 | Autenticação |
| Swashbuckle | 6.x | Swagger/OpenAPI |
| xUnit | 2.6 | Testes |
| Moq | 4.x | Mocks |
| FluentAssertions | 6.x | Assertions |

---

## 📝 Licença

MIT License — VetBook 2024
