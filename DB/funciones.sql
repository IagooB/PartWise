-- ========================================
-- EJEMPLOS DE USO DE LAS FUNCIONES
-- ========================================

-- Ejemplo: Buscar productos equivalentes
-- SELECT * FROM sp_buscar_equivalentes('S.25-801');

-- Ejemplo: Actualizar precio
-- SELECT sp_actualizar_precio(1, 1, 125.50, 'admin', 'Actualización de precios trimestral');

-- ========================================
-- CONSULTAS DE EJEMPLO
-- ========================================

-- Consultar productos por fabricante
-- SELECT * FROM v_productos_completo WHERE fabricante = 'Scanbelt';

-- Productos con área abierta mayor al 35%
-- SELECT codigo_producto, nombre, area_abierta_porcentaje
-- FROM productos
-- WHERE area_abierta_porcentaje SIMILAR TO '[0-9]+%'
--   AND CAST(REGEXP_REPLACE(area_abierta_porcentaje, '%', '') AS INTEGER) > 35;

-- Productos aptos para alimentos
-- SELECT codigo_producto, nombre, fabricante
-- FROM v_productos_completo
-- WHERE apto_alimentos = TRUE;

-- Stock bajo mínimo
-- SELECT * FROM v_productos_inventario WHERE estado_stock = 'REORDENAR';

-- ========================================
-- FIN DEL SCRIPT
-- ========================================
