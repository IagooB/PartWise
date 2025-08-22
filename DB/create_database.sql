-- ========================================
-- 01_create_database.sql
-- Creación de base de datos y schemas
-- PostgreSQL 14+
-- ========================================

-- Terminar conexiones activas (ejecutar como superusuario)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'db_bandas' AND pid <> pg_backend_pid();

-- Eliminar base de datos si existe
DROP DATABASE IF EXISTS db_bandas;

-- Crear base de datos
CREATE DATABASE db_bandas
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'es_ES.UTF-8'
    LC_CTYPE = 'es_ES.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

-- Conectar a la base de datos
\c db_bandas;

-- ========================================
-- CREAR SCHEMAS
-- ========================================

-- Schema principal para tablas de aplicación
CREATE SCHEMA IF NOT EXISTS app
    AUTHORIZATION postgres;

COMMENT ON SCHEMA app IS 'Schema principal para tablas de la aplicación';

-- Schema para vistas
CREATE SCHEMA IF NOT EXISTS views
    AUTHORIZATION postgres;

COMMENT ON SCHEMA views IS 'Schema para vistas de la aplicación';

-- Schema para funciones y procedimientos
CREATE SCHEMA IF NOT EXISTS funcs
    AUTHORIZATION postgres;

COMMENT ON SCHEMA funcs IS 'Schema para funciones y procedimientos almacenados';

-- Schema para datos de auditoría
CREATE SCHEMA IF NOT EXISTS audit
    AUTHORIZATION postgres;

COMMENT ON SCHEMA audit IS 'Schema para tablas de auditoría y logs';

-- Schema para datos temporales y staging
CREATE SCHEMA IF NOT EXISTS staging
    AUTHORIZATION postgres;

COMMENT ON SCHEMA staging IS 'Schema para datos temporales y procesos ETL';

-- ========================================
-- CONFIGURAR SEARCH PATH
-- ========================================

-- Configurar search_path por defecto
ALTER DATABASE db_bandas SET search_path TO app, views, funcs, public;

-- ========================================
-- CREAR EXTENSIONES
-- ========================================

-- Habilitar UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Habilitar búsqueda de texto completo
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Habilitar trigram para búsqueda fuzzy
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Habilitar crosstab para reportes
CREATE EXTENSION IF NOT EXISTS "tablefunc";

-- ========================================
-- CREAR TIPOS CUSTOM
-- ========================================

-- Tipo para estado de producto
DO $$ BEGIN
    CREATE TYPE app.estado_producto AS ENUM ('activo', 'inactivo', 'descontinuado', 'pendiente');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Tipo para tipo de movimiento de inventario
DO $$ BEGIN
    CREATE TYPE app.tipo_movimiento AS ENUM ('entrada', 'salida', 'ajuste', 'transferencia', 'devolucion');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Tipo para tipo de equivalencia
DO $$ BEGIN
    CREATE TYPE app.tipo_equivalencia AS ENUM ('exacta', 'similar', 'alternativa', 'compatible');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Tipo para moneda
DO $$ BEGIN
    CREATE TYPE app.moneda AS ENUM ('EUR', 'USD', 'GBP', 'CNY', 'JPY');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ========================================
-- CONFIGURAR ROLES Y PERMISOS
-- ========================================

-- Crear rol para la aplicación
DO $$ BEGIN
    CREATE ROLE app_user WITH LOGIN PASSWORD 'app_password_cambiar';
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Crear rol para lectura
DO $$ BEGIN
    CREATE ROLE readonly_user WITH LOGIN PASSWORD 'readonly_password_cambiar';
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Otorgar permisos en schemas
GRANT USAGE ON SCHEMA app TO app_user;
GRANT CREATE ON SCHEMA app TO app_user;
GRANT ALL ON ALL TABLES IN SCHEMA app TO app_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA app TO app_user;

GRANT USAGE ON SCHEMA views TO app_user;
GRANT SELECT ON ALL TABLES IN SCHEMA views TO app_user;

GRANT USAGE ON SCHEMA funcs TO app_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA funcs TO app_user;

-- Permisos para usuario de solo lectura
GRANT USAGE ON SCHEMA app TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA app TO readonly_user;
GRANT USAGE ON SCHEMA views TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA views TO readonly_user;

-- Permisos por defecto para objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA app
    GRANT ALL ON TABLES TO app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA app
    GRANT ALL ON SEQUENCES TO app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA views
    GRANT SELECT ON TABLES TO app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA app
    GRANT SELECT ON TABLES TO readonly_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA views
    GRANT SELECT ON TABLES TO readonly_user;

-- ========================================
-- INFORMACIÓN DE LA BASE DE DATOS
-- ========================================

-- Crear tabla de metadatos de la BD
CREATE TABLE IF NOT EXISTS app.db_metadata (
    id SERIAL PRIMARY KEY,
    version VARCHAR(20) NOT NULL,
    description TEXT,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    applied_by VARCHAR(100) DEFAULT CURRENT_USER
);

-- Insertar versión inicial
INSERT INTO app.db_metadata (version, description)
VALUES ('1.0.0', 'Creación inicial de la base de datos');

-- ========================================
-- FIN DEL SCRIPT
-- ========================================

-- Mostrar configuración
\echo 'Base de datos creada exitosamente'
\echo 'Schemas creados: app, views, funcs, audit, staging'
\echo 'Extensiones habilitadas: uuid-ossp, unaccent, pg_trgm, tablefunc'
\echo 'Roles creados: app_user, readonly_user'