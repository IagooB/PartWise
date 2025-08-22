-- ============================================
-- 04_create_views.sql
-- Crear vistas para consultas comunes
-- PostgreSQL 14+
-- ============================================

SET search_path TO partwise, public;

-- ============================================
-- VISTA: Productos con información completa
-- ============================================
CREATE OR REPLACE VIEW v_productos_completo AS
SELECT
    p.id,
    p.codigo_interno,
    p.serie,
    p.modelo,
    f.nombre AS fabricante,
    fp.nombre AS familia,
    fp.codigo AS familia_codigo,
    p.caracteristicas,
    -- Extraer campos comunes del JSONB
    (p.caracteristicas->'dimensiones'->>'paso_mm')::numeric AS paso_mm,
    (p.caracteristicas->'dimensiones'->>'ancho_mm')::numeric AS ancho_mm,
    (p.caracteristicas->'dimensiones'->>'espesor_mm')::numeric AS espesor_mm,
    p.caracteristicas->'materiales' AS materiales,
    (p.caracteristicas->'temperaturas'->>'min_c')::numeric AS temp_min_c,
    (p.caracteristicas->'temperaturas'->>'max_c')::numeric AS temp_max_c,
    p.caracteristicas->'certificaciones' AS certificaciones,
    p.caracteristicas->>'area_abierta' AS area_abierta,
    (p.caracteristicas->>'carga_trabajo_kg')::numeric AS carga_trabajo_kg,
    p.notas,
    p.obsoleto,
    p.activo,
    p.created_at,
    p.updated_at
FROM productos p
LEFT JOIN fabricantes f ON p.fabricante_id = f.id
LEFT JOIN familias_productos fp ON p.familia_id = fp.id;

COMMENT ON VIEW v_productos_completo IS 'Vista completa de productos con campos JSONB extraídos';

-- ============================================
-- VISTA: Inventario con alertas
-- ============================================
CREATE OR REPLACE VIEW v_inventario_alertas AS
SELECT
    i.id,
    p.codigo_interno,
    p.serie,
    p.modelo,
    f.nombre AS fabricante,
    i.cantidad,
    i.stock_minimo,
    i.ubicacion,
    (i.cantidad - i.stock_minimo) AS diferencia,
    CASE
        WHEN i.cantidad = 0 THEN 'SIN_STOCK'
        WHEN i.cantidad < i.stock_minimo THEN 'BAJO_MINIMO'
        WHEN i.cantidad < (i.stock_minimo * 1.5) THEN 'PROXIMO_MINIMO'
        ELSE 'OK'
    END AS estado,
    i.ultima_actualizacion
FROM inventario i
JOIN productos p ON i.producto_id = p.id
LEFT JOIN fabricantes f ON p.fabricante_id = f.id
WHERE p.activo = TRUE AND p.obsoleto = FALSE;

COMMENT ON VIEW v_inventario_alertas IS 'Vista de inventario con estados de alerta';

-- ============================================
-- VISTA: Productos disponibles por proveedor
-- ============================================
CREATE OR REPLACE VIEW v_productos_proveedor AS
SELECT
    prov.nombre AS proveedor,
    f.nombre AS fabricante,
    p.serie,
    p.modelo,
    pp.codigo_proveedor,
    pp.precio_lista,
    pp.moneda,
    pp.tiempo_entrega_dias,
    pp.url_producto,
    pp.disponible,
    i.cantidad AS stock_actual,
    pp.updated_at AS ultima_actualizacion_precio
FROM productos_proveedores pp
JOIN productos p ON pp.producto_id = p.id
JOIN proveedores prov ON pp.proveedor_id = prov.id
LEFT JOIN fabricantes f ON p.fabricante_id = f.id
LEFT JOIN inventario i ON p.id = i.producto_id
WHERE pp.disponible = TRUE
  AND p.activo = TRUE
  AND p.obsoleto = FALSE
  AND prov.activo = TRUE;

COMMENT ON VIEW v_productos_proveedor IS 'Productos disponibles por proveedor con precios';

-- ============================================
-- VISTA: Búsqueda rápida de productos
-- ============================================
CREATE OR REPLACE VIEW v_busqueda_productos AS
SELECT
    p.id,
    p.codigo_interno,
    COALESCE(p.codigo_interno, '') || ' ' ||
    COALESCE(f.nombre, '') || ' ' ||
    COALESCE(p.serie, '') || ' ' ||
    p.modelo || ' ' ||
    COALESCE(fp.nombre, '') AS texto_busqueda,
    f.nombre AS fabricante,
    p.serie,
    p.modelo,
    fp.nombre AS familia,
    p.caracteristicas->>'color' AS color,
    p.caracteristicas->>'superficie' AS superficie,
    COALESCE(
        (SELECT json_agg(DISTINCT materiales)
         FROM jsonb_array_elements_text(p.caracteristicas->'materiales') AS materiales),
        '[]'::json
    ) AS materiales
FROM productos p
LEFT JOIN fabricantes f ON p.fabricante_id = f.id
LEFT JOIN familias_productos fp ON p.familia_id = fp.id
WHERE p.activo = TRUE AND p.obsoleto = FALSE;

COMMENT ON VIEW v_busqueda_productos IS 'Vista optimizada para búsquedas de texto completo';

-- ============================================
-- VISTA: Estadísticas por fabricante
-- ============================================
CREATE OR REPLACE VIEW v_estadisticas_fabricante AS
SELECT
    f.id,
    f.nombre AS fabricante,
    COUNT(DISTINCT p.id) AS total_productos,
    COUNT(DISTINCT p.serie) AS total_series,
    COUNT(DISTINCT p.familia_id) AS familias_cubiertas,
    array_agg(DISTINCT fp.nombre) AS familias,
    COUNT(DISTINCT pp.proveedor_id) AS proveedores_disponibles,
    MAX(p.updated_at) AS ultima_actualizacion
FROM fabricantes f
LEFT JOIN productos p ON f.id = p.fabricante_id AND p.activo = TRUE
LEFT JOIN familias_productos fp ON p.familia_id = fp.id
LEFT JOIN productos_proveedores pp ON p.id = pp.producto_id
WHERE f.activo = TRUE
GROUP BY f.id, f.nombre;

COMMENT ON VIEW v_estadisticas_fabricante IS 'Estadísticas de productos por fabricante';

-- ============================================
-- VISTA: Productos con documentación
-- ============================================
CREATE OR REPLACE VIEW v_productos_documentos AS
SELECT
    p.id AS producto_id,
    p.codigo_interno,
    f.nombre AS fabricante,
    p.serie,
    p.modelo,
    COUNT(d.id) AS total_documentos,
    json_agg(
        json_build_object(
            'tipo', d.tipo,
            'nombre', d.nombre_archivo,
            'descripcion', d.descripcion,
            'fecha', d.created_at
        ) ORDER BY d.created_at DESC
    ) FILTER (WHERE d.id IS NOT NULL) AS documentos
FROM productos p
LEFT JOIN fabricantes f ON p.fabricante_id = f.id
LEFT JOIN documentos d ON p.id = d.producto_id
WHERE p.activo = TRUE
GROUP BY p.id, p.codigo_interno, f.nombre, p.serie, p.modelo;

COMMENT ON VIEW v_productos_documentos IS 'Productos con su documentación asociada';

-- ============================================
-- VISTA MATERIALIZADA: Para búsquedas rápidas
-- ============================================
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_busqueda_rapida AS
SELECT
    p.id,
    p.codigo_interno,
    f.nombre AS fabricante,
    p.serie,
    p.modelo,
    fp.nombre AS familia,
    to_tsvector('spanish',
        COALESCE(p.codigo_interno, '') || ' ' ||
        COALESCE(f.nombre, '') || ' ' ||
        COALESCE(p.serie, '') || ' ' ||
        p.modelo || ' ' ||
        COALESCE(fp.nombre, '') || ' ' ||
        COALESCE(p.caracteristicas::text, '')
    ) AS search_vector
FROM productos p
LEFT JOIN fabricantes f ON p.fabricante_id = f.id
LEFT JOIN familias_productos fp ON p.familia_id = fp.id
WHERE p.activo = TRUE AND p.obsoleto = FALSE;

-- Índice para búsqueda de texto completo
CREATE INDEX IF NOT EXISTS idx_mv_busqueda_rapida_search
    ON mv_busqueda_rapida USING gin(search_vector);

-- Índice único para refresh concurrente
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_busqueda_rapida_id
    ON mv_busqueda_rapida(id);

COMMENT ON MATERIALIZED VIEW mv_busqueda_rapida IS 'Vista materializada para búsquedas de texto completo';

-- Función para refrescar la vista materializada
CREATE OR REPLACE FUNCTION refresh_busqueda_rapida()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_busqueda_rapida;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION refresh_busqueda_rapida() IS 'Refresca la vista materializada de búsqueda';