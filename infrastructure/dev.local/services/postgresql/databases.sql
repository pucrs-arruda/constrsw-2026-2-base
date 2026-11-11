-- Script de inicialização dos bancos de dados para o projeto ConstrSW
-- Este script deve ser executado como usuário postgres

-- =====================================================
-- FASE 1: Conectar como postgres e criar usuários
-- =====================================================

-- Conectar como postgres (usuário padrão)
\c postgres;

-- Criação de usuários para cada serviço com permissão CREATEDB
CREATE USER sonar WITH PASSWORD 'a12345678' CREATEDB;
CREATE USER classes WITH PASSWORD 'a12345678' CREATEDB;
CREATE USER courses WITH PASSWORD 'a12345678' CREATEDB;
CREATE USER employees WITH PASSWORD 'a12345678' CREATEDB;
CREATE USER lessons WITH PASSWORD 'a12345678' CREATEDB;
CREATE USER professors WITH PASSWORD 'a12345678' CREATEDB;
CREATE USER reservations WITH PASSWORD 'a12345678' CREATEDB;
CREATE USER resources WITH PASSWORD 'a12345678' CREATEDB;
CREATE USER rooms WITH PASSWORD 'a12345678' CREATEDB;
CREATE USER students WITH PASSWORD 'a12345678' CREATEDB;

-- =====================================================
-- FASE 2: Criar bancos de dados como postgres
-- =====================================================

-- Criar todos os bancos de dados como usuário postgres
CREATE DATABASE sonar TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'pt_BR.utf8' LC_CTYPE 'pt_BR.utf8' TABLESPACE pg_default CONNECTION LIMIT -1;
CREATE DATABASE classes TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'pt_BR.utf8' LC_CTYPE 'pt_BR.utf8' TABLESPACE pg_default CONNECTION LIMIT -1;
CREATE DATABASE courses TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'pt_BR.utf8' LC_CTYPE 'pt_BR.utf8' TABLESPACE pg_default CONNECTION LIMIT -1;
CREATE DATABASE employees TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'pt_BR.utf8' LC_CTYPE 'pt_BR.utf8' TABLESPACE pg_default CONNECTION LIMIT -1;
CREATE DATABASE lessons TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'pt_BR.utf8' LC_CTYPE 'pt_BR.utf8' TABLESPACE pg_default CONNECTION LIMIT -1;
CREATE DATABASE professors TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'pt_BR.utf8' LC_CTYPE 'pt_BR.utf8' TABLESPACE pg_default CONNECTION LIMIT -1;
CREATE DATABASE reservations TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'pt_BR.utf8' LC_CTYPE 'pt_BR.utf8' TABLESPACE pg_default CONNECTION LIMIT -1;
CREATE DATABASE resources TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'pt_BR.utf8' LC_CTYPE 'pt_BR.utf8' TABLESPACE pg_default CONNECTION LIMIT -1;
CREATE DATABASE rooms TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'pt_BR.utf8' LC_CTYPE 'pt_BR.utf8' TABLESPACE pg_default CONNECTION LIMIT -1;
CREATE DATABASE students TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'pt_BR.utf8' LC_CTYPE 'pt_BR.utf8' TABLESPACE pg_default CONNECTION LIMIT -1;

-- =====================================================
-- FASE 3: Conceder privilégios aos usuários em seus respectivos bancos
-- =====================================================

-- Conceder privilégios completos aos usuários em seus respectivos bancos
GRANT ALL PRIVILEGES ON DATABASE sonar TO sonar;
GRANT ALL PRIVILEGES ON DATABASE classes TO classes;
GRANT ALL PRIVILEGES ON DATABASE courses TO courses;
GRANT ALL PRIVILEGES ON DATABASE employees TO employees;
GRANT ALL PRIVILEGES ON DATABASE lessons TO lessons;
GRANT ALL PRIVILEGES ON DATABASE professors TO professors;
GRANT ALL PRIVILEGES ON DATABASE reservations TO reservations;
GRANT ALL PRIVILEGES ON DATABASE resources TO resources;
GRANT ALL PRIVILEGES ON DATABASE rooms TO rooms;
GRANT ALL PRIVILEGES ON DATABASE students TO students;

-- =====================================================
-- FASE 4: Configurar privilégios do schema public para cada banco
-- =====================================================

-- Configurar privilégios para o banco classes
\c classes;
GRANT ALL ON SCHEMA public TO classes;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO classes;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO classes;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO classes;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO classes;

-- Configurar privilégios para o banco courses
\c courses;
GRANT ALL ON SCHEMA public TO courses;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO courses;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO courses;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO courses;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO courses;

-- Configurar privilégios para o banco employees
\c employees;
GRANT ALL ON SCHEMA public TO employees;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO employees;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO employees;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO employees;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO employees;

-- Configurar privilégios para o banco lessons
\c lessons;
GRANT ALL ON SCHEMA public TO lessons;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO lessons;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO lessons;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO lessons;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO lessons;

-- Configurar privilégios para o banco professors
\c professors;
GRANT ALL ON SCHEMA public TO professors;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO professors;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO professors;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO professors;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO professors;

-- Configurar privilégios para o banco reservations
\c reservations;
GRANT ALL ON SCHEMA public TO reservations;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO reservations;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO reservations;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO reservations;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO reservations;

-- Configurar privilégios para o banco resources
\c resources;
GRANT ALL ON SCHEMA public TO resources;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO resources;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO resources;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO resources;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO resources;

-- Configurar privilégios para o banco rooms
\c rooms;
GRANT ALL ON SCHEMA public TO rooms;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rooms;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rooms;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO rooms;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO rooms;

-- Configurar privilégios para o banco students
\c students;
GRANT ALL ON SCHEMA public TO students;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO students;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO students;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO students;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO students;

-- Configurar privilégios para o banco sonar
\c sonar;
GRANT ALL ON SCHEMA public TO sonar;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO sonar;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO sonar;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO sonar;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO sonar;

-- =====================================================
-- FASE 5: Verificação final
-- =====================================================

-- Listar todos os bancos de dados criados
SELECT datname FROM pg_database WHERE datname IN ('sonar', 'classes', 'courses', 'employees', 'lessons', 'professors', 'reservations', 'resources', 'rooms', 'students') ORDER BY datname;

-- Listar todos os usuários criados
SELECT usename FROM pg_user WHERE usename IN ('sonar', 'classes', 'courses', 'employees', 'lessons', 'professors', 'reservations', 'resources', 'rooms', 'students') ORDER BY usename;
