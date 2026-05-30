FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

COPY ["src/API/VetBook.API.csproj", "src/API/"]
COPY ["src/SharedKernel/VetBook.SharedKernel.csproj", "src/SharedKernel/"]
COPY ["src/CadastroContext/Domain/VetBook.CadastroContext.Domain.csproj", "src/CadastroContext/Domain/"]
COPY ["src/CadastroContext/Application/VetBook.CadastroContext.Application.csproj", "src/CadastroContext/Application/"]
COPY ["src/CadastroContext/Infrastructure/VetBook.CadastroContext.Infrastructure.csproj", "src/CadastroContext/Infrastructure/"]
COPY ["src/VeterinarioContext/Domain/VetBook.VeterinarioContext.Domain.csproj", "src/VeterinarioContext/Domain/"]
COPY ["src/VeterinarioContext/Application/VetBook.VeterinarioContext.Application.csproj", "src/VeterinarioContext/Application/"]
COPY ["src/VeterinarioContext/Infrastructure/VetBook.VeterinarioContext.Infrastructure.csproj", "src/VeterinarioContext/Infrastructure/"]
COPY ["src/AgendamentoContext/Domain/VetBook.AgendamentoContext.Domain.csproj", "src/AgendamentoContext/Domain/"]
COPY ["src/AgendamentoContext/Application/VetBook.AgendamentoContext.Application.csproj", "src/AgendamentoContext/Application/"]
COPY ["src/AgendamentoContext/Infrastructure/VetBook.AgendamentoContext.Infrastructure.csproj", "src/AgendamentoContext/Infrastructure/"]

RUN dotnet restore "src/API/VetBook.API.csproj"

COPY . .

WORKDIR "/src/src/API"
RUN dotnet build "VetBook.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
RUN dotnet publish "VetBook.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "VetBook.API.dll"]
