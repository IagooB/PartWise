-- ============================================
-- 03_create_indexes.sql
-- Crear índices para optimización de consultas
-- PostgreSQL 14+
-- ============================================

SET search_path TO partwise, public;

-- ============================================
-- ÍNDICES: Búsquedas de texto
-- ============================================
-- Índices para búsquedas fuzzy con pg_trgm
CREATE INDEX IF NOT EXISTS idx_fabricantes_nombre_trgm
    ON fabricantes USING gin(nombre gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_proveedores_nombre_trgm
    ON proveedores USING gin(nombre gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_productos_modelo_trgm
    ON productos USING gin(modelo gin_trgm_ops);

-- ============================================
-- ÍNDICES: Búsquedas por campos específicos
-- ============================================
-- Fabricantes
CREATE INDEX IF NOT EXISTS idx_fabricantes_activo
    ON fabricantes(activo)
    WHERE activo = TRUE;

CREATE INDEX IF NOT EXISTS idx_fabricantes_familias
    ON fabricantes USING gin(familias_productos);

-- Productos
CREATE INDEX IF NOT EXISTS idx_productos_fabricante
    ON productos(fabricante_id);

CREATE INDEX IF NOT EXISTS idx_productos_familia
    ON productos(familia_id);

CREATE INDEX IF NOT EXISTS idx_productos_serie
    ON productos(serie);

CREATE INDEX IF NOT EXISTS idx_productos_codigo
    ON productos(codigo_interno)
    WHERE codigo_interno IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_productos_activo_no_obsoleto
    ON productos(activo, obsoleto)
    WHERE activo = TRUE AND obsoleto = FALSE;

-- ============================================
-- ÍNDICES: JSONB para características
-- ============================================
-- Índice GIN para búsquedas en todo el JSONB
CREATE INDEX IF NOT EXISTS idx_productos_caracteristicas
    ON productos USING gin(caracteristicas);

-- Índices específicos para campos frecuentes en JSONB
CREATE INDEX IF NOT EXISTS idx_productos_paso
    ON productos((caracteristicas->'dimensiones'->>'paso_mm'))
    WHERE caracteristicas->'dimensiones'->>'paso_mm' IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_productos_materiales
    ON productos USING gin((caracteristicas->'materiales'));

CREATE INDEX IF NOT EXISTS idx_productos_certificaciones
    ON productos USING gin((caracteristicas->'certificaciones'));

CREATE INDEX IF NOT EXISTS idx_productos_temp_max
    ON productos(((caracteristicas->'temperaturas'->>'max_c')::numeric))
    WHERE caracteristicas->'temperaturas'->>'max_c' IS NOT NULL;

-- ============================================
-- ÍNDICES: Relaciones y foreign keys
-- ============================================
CREATE INDEX IF NOT EXISTS idx_productos_proveedores_producto
    ON productos_proveedores(producto_id);

CREATE INDEX IF NOT EXISTS idx_productos_proveedores_proveedor
    ON productos_proveedores(proveedor_id);

CREATE INDEX IF NOT EXISTS idx_productos_proveedores_disponible
    ON productos_proveedores(disponible)
    WHERE disponible = TRUE;

CREATE INDEX IF NOT EXISTS idx_inventario_producto
    ON inventario(producto_id);

CREATE INDEX IF NOT EXISTS idx_inventario_bajo_minimo
    ON inventario(producto_id, cantidad, stock_minimo)
    WHERE cantidad < stock_minimo;

CREATE INDEX IF NOT EXISTS idx_documentos_producto
    ON documentos(producto_id);

CREATE INDEX IF NOT EXISTS idx_documentos_tipo
    ON documentos(tipo);

-- ============================================
-- ÍNDICES: Ordenamiento frecuente
-- ============================================
CREATE INDEX IF NOT EXISTS idx_productos_created_at_desc
    ON productos(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_familias_orden_nombre
    ON familias_productos(orden, nombre);

-- ============================================
-- ESTADÍSTICAS: Actualizar estadísticas de tablas
-- ============================================
ANALYZE fabricantes;
ANALYZE proveedores;
ANALYZE familias_productos;
ANALYZE productos;
ANALYZE productos_proveedores;
ANALYZE inventario;
ANALYZE documentos;