-- ============================================================
-- VetBook - Seed de Dados Iniciais
-- Execute após rodar as migrations / EnsureCreated
-- ============================================================

USE VetBookDb;
GO

-- ============================================================
-- VETERINÁRIOS
-- ============================================================
INSERT INTO [Veterinario].[Veterinarios]
    (Id, Nome, Crmv, Especialidade, Email, Telefone, Ativo, DataCadastro)
VALUES
    (NEWID(), 'Dr. Carlos Andrade',   'SP-12345', 'Clínica Geral',       'carlos@vetbook.com',   '11987654321', 1, GETUTCDATE()),
    (NEWID(), 'Dra. Ana Souza',       'SP-67890', 'Dermatologia',         'ana@vetbook.com',      '11976543210', 1, GETUTCDATE()),
    (NEWID(), 'Dr. Bruno Lima',       'RJ-11111', 'Ortopedia',            'bruno@vetbook.com',    '21987654321', 1, GETUTCDATE()),
    (NEWID(), 'Dra. Fernanda Costa',  'MG-22222', 'Oftalmologia',         'fernanda@vetbook.com', '31987654321', 1, GETUTCDATE()),
    (NEWID(), 'Dr. Ricardo Mendes',   'SP-33333', 'Oncologia',            'ricardo@vetbook.com',  '11998765432', 0, GETUTCDATE());
GO

-- ============================================================
-- DONOS
-- ============================================================
DECLARE @Dono1 UNIQUEIDENTIFIER = NEWID();
DECLARE @Dono2 UNIQUEIDENTIFIER = NEWID();
DECLARE @Dono3 UNIQUEIDENTIFIER = NEWID();

INSERT INTO [Cadastro].[Donos]
    (Id, Nome, Cpf, Email, Telefone, Endereco, DataCadastro)
VALUES
    (@Dono1, 'Maria Oliveira',  '52998224725', 'maria@email.com',  '11987654321', 'Rua das Flores, 100 - São Paulo/SP',   GETUTCDATE()),
    (@Dono2, 'João Santos',     '87748408000', 'joao@email.com',   '11976543210', 'Av. Paulista, 500 - São Paulo/SP',     GETUTCDATE()),
    (@Dono3, 'Lucia Ferreira',  '37340633520', 'lucia@email.com',  '21987654321', 'Rua do Catete, 200 - Rio de Janeiro/RJ', GETUTCDATE());
GO

-- ============================================================
-- PETS
-- ============================================================
DECLARE @Dono1 UNIQUEIDENTIFIER = (SELECT TOP 1 Id FROM [Cadastro].[Donos] WHERE Nome = 'Maria Oliveira');
DECLARE @Dono2 UNIQUEIDENTIFIER = (SELECT TOP 1 Id FROM [Cadastro].[Donos] WHERE Nome = 'João Santos');
DECLARE @Dono3 UNIQUEIDENTIFIER = (SELECT TOP 1 Id FROM [Cadastro].[Donos] WHERE Nome = 'Lucia Ferreira');

INSERT INTO [Cadastro].[Pets]
    (Id, Nome, Especie, Raca, Idade, Peso, Sexo, Observacoes, DonoId, DataCadastro)
VALUES
    (NEWID(), 'Rex',     'Cachorro', 'Labrador Retriever', 3, 28.50, 'Macho',  'Vacinado em dia',            @Dono1, GETUTCDATE()),
    (NEWID(), 'Mia',     'Gato',     'Persa',              2, 3.80,  'Femea',  'Alérgica a certos alimentos', @Dono1, GETUTCDATE()),
    (NEWID(), 'Thor',    'Cachorro', 'Golden Retriever',   5, 32.00, 'Macho',  NULL,                          @Dono2, GETUTCDATE()),
    (NEWID(), 'Luna',    'Gato',     'Siamês',             1, 2.50,  'Femea',  'Gata nova, muito ativa',      @Dono2, GETUTCDATE()),
    (NEWID(), 'Bolinha', 'Cachorro', 'Poodle',             7, 5.20,  'Macho',  'Idoso, pressão alta',         @Dono3, GETUTCDATE());
GO

PRINT 'Seed executado com sucesso!';
GO
