-- ============================================
-- 02_create_tables.sql
-- Crear tablas principales (versión simplificada)
-- PostgreSQL 14+
-- ============================================

SET search_path TO partwise, public;

-- ============================================
-- TABLA: fabricantes
-- ============================================
CREATE TABLE IF NOT EXISTS fabricantes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(200) NOT NULL UNIQUE,
    sitio_web VARCHAR(255),
    email VARCHAR(100),
    familias_productos TEXT[], -- Array de familias que fabrican
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE fabricantes IS 'Fabricantes de bandas y componentes';
COMMENT ON COLUMN fabricantes.familias_productos IS 'Array con las familias de productos que fabrica';

-- ============================================
-- TABLA: proveedores
-- ============================================
CREATE TABLE IF NOT EXISTS proveedores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(200) NOT NULL UNIQUE,
    sitio_web VARCHAR(255),
    email VARCHAR(100),
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE proveedores IS 'Proveedores y distribuidores';

-- ============================================
-- TABLA: familias_productos (catálogo)
-- ============================================
CREATE TABLE IF NOT EXISTS familias_productos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    orden INTEGER DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE familias_productos IS 'Catálogo de familias de productos';

-- ============================================
-- TABLA: productos
-- ============================================
CREATE TABLE IF NOT EXISTS productos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Identificación básica
    fabricante_id UUID REFERENCES fabricantes(id) ON DELETE RESTRICT,
    familia_id UUID REFERENCES familias_productos(id) ON DELETE RESTRICT,
    serie VARCHAR(100),
    modelo VARCHAR(100) NOT NULL,
    codigo_interno VARCHAR(100) UNIQUE,

    -- Características en JSONB (flexible)
    caracteristicas JSONB DEFAULT '{}',
    /* Ejemplo de estructura JSONB:
    {
        "dimensiones": {
            "paso_mm": 25.4,
            "ancho_mm": 600,
            "espesor_mm": 12
        },
        "materiales": ["PP", "PE", "POM"],
        "temperaturas": {
            "min_c": -20,
            "max_c": 80
        },
        "certificaciones": ["FDA", "EU"],
        "area_abierta": "41%",
        "carga_trabajo_kg": 1000,
        "aplicaciones": ["alimentación", "farmacia"],
        "color": "azul",
        "superficie": "lisa"
    }
    */

    -- Metadatos
    notas TEXT,
    obsoleto BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    -- Constraint único para evitar duplicados
    CONSTRAINT uk_producto_fabricante_serie_modelo
        UNIQUE(fabricante_id, serie, modelo)
);

COMMENT ON TABLE productos IS 'Catálogo de productos con características flexibles en JSONB';
COMMENT ON COLUMN productos.caracteristicas IS 'Características técnicas en formato JSON flexible';

-- ============================================
-- TABLA: productos_proveedores (relación N:M)
-- ============================================
CREATE TABLE IF NOT EXISTS productos_proveedores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
    proveedor_id UUID REFERENCES proveedores(id) ON DELETE CASCADE,
    codigo_proveedor VARCHAR(100),
    precio_lista DECIMAL(12,2),
    moneda VARCHAR(3) DEFAULT 'EUR',
    disponible BOOLEAN DEFAULT TRUE,
    tiempo_entrega_dias INTEGER,
    url_producto VARCHAR(500),
    notas TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_producto_proveedor UNIQUE(producto_id, proveedor_id)
);

COMMENT ON TABLE productos_proveedores IS 'Relación entre productos y sus proveedores con precios';

-- ============================================
-- TABLA: inventario (simplificada)
-- ============================================
CREATE TABLE IF NOT EXISTS inventario (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
    cantidad DECIMAL(12,2) DEFAULT 0,
    ubicacion VARCHAR(50),
    stock_minimo DECIMAL(12,2) DEFAULT 0,
    notas TEXT,
    ultima_actualizacion TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uk_inventario_producto UNIQUE(producto_id)
);

COMMENT ON TABLE inventario IS 'Control de inventario simplificado';

-- ============================================
-- TABLA: documentos (para PDFs técnicos)
-- ============================================
CREATE TABLE IF NOT EXISTS documentos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
    tipo VARCHAR(50), -- 'ficha_tecnica', 'manual', 'certificado', etc.
    nombre_archivo VARCHAR(255) NOT NULL,
    ruta_archivo VARCHAR(500),
    url_externa VARCHAR(500),
    descripcion TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE documentos IS 'Documentos técnicos asociados a productos';

-- ============================================
-- FUNCIONES: Actualizar timestamp
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS: Auto-actualizar updated_at
-- ============================================
CREATE TRIGGER update_fabricantes_updated_at
    BEFORE UPDATE ON fabricantes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_proveedores_updated_at
    BEFORE UPDATE ON proveedores
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_productos_updated_at
    BEFORE UPDATE ON productos
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_productos_proveedores_updated_at
    BEFORE UPDATE ON productos_proveedores
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();