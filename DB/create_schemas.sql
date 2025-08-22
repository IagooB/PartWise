-- ============================================
-- 01_create_schemas.sql
-- Crear esquemas y configuración inicial
-- PostgreSQL 14+
-- ============================================

-- Eliminar esquema si existe (solo para desarrollo)
DROP SCHEMA IF EXISTS partwise CASCADE;

-- Crear esquema principal
CREATE SCHEMA partwise;

-- Establecer el esquema por defecto
SET search_path TO partwise, public;

-- Comentarios del esquema
COMMENT ON SCHEMA partwise IS 'Sistema de gestión de piezas de bandas transportadoras';

-- Crear extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  -- Para generar UUIDs
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- Para búsquedas de texto fuzzy

-- Configurar timezone (ajustar según ubicación)
SET timezone = 'Europe/Madrid';