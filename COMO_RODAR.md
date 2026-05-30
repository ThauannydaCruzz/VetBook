# 🚀 Como Rodar o VetBook

Sistema veterinário completo — **Backend .NET 8** + **Frontend Flutter**.

---

## 📁 Estrutura do Projeto

```
VetBook/
├── backend/               ← ASP.NET Core Web API (DDD + Clean Architecture)
│   ├── src/
│   │   ├── API/           ← Controllers, Auth, Middlewares
│   │   ├── SharedKernel/  ← Entidades base, Value Objects, interfaces
│   │   ├── CadastroContext/   ← Donos e Pets
│   │   ├── VeterinarioContext/ ← Veterinários
│   │   └── AgendamentoContext/ ← Consultas
│   ├── tests/             ← Testes unitários e de integração
│   ├── scripts/           ← PowerShell para migrations
│   ├── Dockerfile
│   └── docker-compose.yml
│
└── frontend/
    └── sistema_vet/       ← App Flutter integrado com a API
        ├── lib/
        │   ├── main.dart
        │   ├── models/    ← DTOs e modelos
        │   ├── services/  ← Camada de acesso à API
        │   ├── screens/   ← Telas do app
        │   ├── widgets/   ← Componentes reutilizáveis
        │   └── utils/     ← Cores, constantes
        └── assets/        ← Imagens e recursos
```

---

## 🔵 PASSO 1 — Rodar o Backend

Abra um terminal na pasta `backend/`:

```bash
cd backend
```

### ✅ Opção A — Com Docker (recomendado)

> Requer: **Docker Desktop** instalado e rodando

```bash
docker-compose up -d
```

Aguarde ~30 segundos. Isso irá:
- Subir o **SQL Server 2022** na porta `1433`
- Compilar e subir a **API** na porta `8080`
- Criar o banco de dados automaticamente

**Verifique se está funcionando:**
- Health check: http://localhost:8080/health
- Swagger: http://localhost:8080 (ou http://localhost:8080/swagger)

---

### Opção B — Sem Docker (.NET local)

> Requer: **.NET 8 SDK** e **SQL Server** instalado localmente

```bash
# 1. Restaurar pacotes
dotnet restore

# 2. Instalar EF Tools (apenas na primeira vez)
dotnet tool install --global dotnet-ef

# 3. Rodar a API na porta 8080 (o banco é criado automaticamente)
dotnet run --project src/API --urls http://localhost:8080
```

**Swagger:** http://localhost:8080

> Se precisar mudar a connection string, edite `src/API/appsettings.json`

---

## 🟣 PASSO 2 — Configurar o Frontend

Abra `frontend/sistema_vet/lib/utils/constants.dart` e ajuste a URL da API:

```dart
// Emulador Android (padrão):
static const String baseUrl = 'http://10.0.2.2:8080';

// iOS Simulator:
static const String baseUrl = 'http://localhost:8080';

// Dispositivo físico (substitua pelo seu IP):
// Execute: ipconfig (Windows) ou ifconfig (Mac/Linux)
static const String baseUrl = 'http://192.168.x.x:8080';

// Flutter Web:
static const String baseUrl = 'http://localhost:8080';
```

---

## 🟢 PASSO 3 — Rodar o Frontend

Abra **outro terminal** na pasta `frontend/sistema_vet/`:

```bash
cd frontend/sistema_vet

# Instalar dependências
flutter pub get

# Ver dispositivos disponíveis
flutter devices

# Rodar no emulador/dispositivo
flutter run
```

---

## 🔐 PASSO 4 — Login

Na tela inicial do app:

| Usuário | Senha | Acesso |
|---|---|---|
| `admin` | `Admin@123!` | Total (inclui painel Admin) |
| `veterinario` | `Vet@123!` | Geral |

---

## ✅ PASSO 5 — Testando o Sistema

### Via App Flutter:
1. Faça login com `admin / Admin@123!`
2. Aba **Admin** → cadastre um **Veterinário**
3. Aba **Admin** → cadastre um **Dono/Tutor**
4. Aba **Meus Pets** → cadastre um **Pet** (informe o ID do dono)
5. Tela **Início** → toque no banner de agendamento
6. Selecione veterinário → pet → data/hora → confirme
7. Aba **Consultas** → acompanhe e cancele se necessário

### Via Swagger (browser):
1. Acesse **http://localhost:8080**
2. Em **🔐 Auth → POST /api/auth/login**, faça login
3. Copie o `token` da resposta
4. Clique em **Authorize 🔒** (topo da página) → cole `Bearer SEU_TOKEN`
5. Agora todos os endpoints estão desbloqueados
6. Siga o fluxo: **👤 Donos → 🐾 Pets → 🩺 Veterinários → 📅 Consultas**

---

## 🛑 Parar o Projeto

```bash
# Parar o Docker
cd backend && docker-compose down

# Parar a API no terminal: Ctrl+C
# Parar o Flutter no terminal: q (ou Ctrl+C)
```

---

## ❗ Problemas Comuns

| Problema | Solução |
|---|---|
| App não conecta à API | Verifique a URL em `constants.dart` e se o backend está rodando |
| `flutter: command not found` | Adicione o Flutter ao PATH e reinicie o terminal |
| `docker: command not found` | Instale o Docker Desktop e reinicie |
| SQL Server demora a subir | Aguarde 30–60s após `docker-compose up -d` |
| Porta 8080 ocupada | Mude para 8081 no `docker-compose.yml` e em `constants.dart` |
| Erro de CPF inválido | Use um CPF válido (ex: `529.982.247-25`) |

---

## 🛠️ Pré-requisitos

| Ferramenta | Link |
|---|---|
| .NET 8 SDK | https://dotnet.microsoft.com/download/dotnet/8 |
| Docker Desktop | https://www.docker.com/products/docker-desktop |
| Flutter SDK | https://docs.flutter.dev/get-started/install |
| Android Studio | https://developer.android.com/studio |
