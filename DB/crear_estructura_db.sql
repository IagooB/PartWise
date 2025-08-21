-- ========================================
-- BASE DE DATOS DE BANDAS MODULARES Y TRANSPORTADORAS
-- Versión 2.0 - Estructura Completa - PostgreSQL
-- ========================================

-- Eliminar tablas si existen (en orden inverso por las claves foráneas)
DROP TABLE IF EXISTS equivalencias_productos CASCADE;
DROP TABLE IF EXISTS historial_precios CASCADE;
DROP TABLE IF EXISTS inventario CASCADE;
DROP TABLE IF EXISTS productos_proveedores CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS subcategorias CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS contactos_proveedores CASCADE;
DROP TABLE IF EXISTS proveedores CASCADE;
DROP TABLE IF EXISTS distribuidores CASCADE;
DROP TABLE IF EXISTS fabricantes CASCADE;

-- Eliminar vistas si existen
DROP VIEW IF EXISTS v_productos_completo CASCADE;
DROP VIEW IF EXISTS v_equivalencias_marcas CASCADE;
DROP VIEW IF EXISTS v_productos_inventario CASCADE;
DROP VIEW IF EXISTS v_productos_por_paso CASCADE;

-- Eliminar funciones si existen
DROP FUNCTION IF EXISTS sp_buscar_equivalentes(VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS sp_actualizar_precio(INT, INT, DECIMAL, VARCHAR, VARCHAR) CASCADE;

-- ========================================
-- 1. TABLA DE FABRICANTES
-- ========================================
CREATE TABLE fabricantes (
    id_fabricante SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais VARCHAR(50),
    sitio_web VARCHAR(255),
    catalogo_url VARCHAR(500),
    notas TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- ========================================
-- 2. TABLA DE DISTRIBUIDORES
-- ========================================
CREATE TABLE distribuidores (
    id_distribuidor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    pais VARCHAR(50),
    region VARCHAR(100),
    sitio_web VARCHAR(255),
    telefono VARCHAR(50),
    email VARCHAR(100),
    direccion TEXT,
    notas TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- ========================================
-- 3. TABLA DE PROVEEDORES (Relación Fabricante-Distribuidor)
-- ========================================
CREATE TABLE proveedores (
    id_proveedor SERIAL PRIMARY KEY,
    id_fabricante INTEGER,
    id_distribuidor INTEGER,
    codigo_proveedor VARCHAR(50),
    nombre_comercial VARCHAR(100),
    condiciones_pago VARCHAR(100),
    tiempo_entrega_dias INTEGER,
    descuento_general DECIMAL(5,2),
    notas TEXT,
    fecha_inicio DATE,
    fecha_fin DATE,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_fabricante) REFERENCES fabricantes(id_fabricante),
    FOREIGN KEY (id_distribuidor) REFERENCES distribuidores(id_distribuidor)
);

-- ========================================
-- 4. TABLA DE CONTACTOS DE PROVEEDORES
-- ========================================
CREATE TABLE contactos_proveedores (
    id_contacto SERIAL PRIMARY KEY,
    id_proveedor INTEGER,
    nombre VARCHAR(100),
    cargo VARCHAR(100),
    telefono VARCHAR(50),
    email VARCHAR(100),
    notas TEXT,
    principal BOOLEAN DEFAULT FALSE,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

-- ========================================
-- 5. TABLA DE CATEGORÍAS
-- ========================================
CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- ========================================
-- 6. TABLA DE SUBCATEGORÍAS
-- ========================================
CREATE TABLE subcategorias (
    id_subcategoria SERIAL PRIMARY KEY,
    id_categoria INTEGER,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- ========================================
-- 7. TABLA DE PRODUCTOS (Estructura ampliada)
-- ========================================
CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    id_fabricante INTEGER,
    id_subcategoria INTEGER,

    -- Identificación básica
    codigo_producto VARCHAR(100) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    grupo VARCHAR(100),
    familia VARCHAR(100),

    -- Especificaciones técnicas principales
    tipo VARCHAR(100),
    serie VARCHAR(50),
    paso_nominal VARCHAR(50),
    paso_mm DECIMAL(10,2),
    ancho_estandar VARCHAR(100),
    ancho_minimo DECIMAL(10,2),
    ancho_maximo DECIMAL(10,2),

    -- Características de superficie
    superficie_correa VARCHAR(100),
    superficie_tipo VARCHAR(100),
    textura VARCHAR(100),
    color VARCHAR(50),

    -- Características de área abierta
    area_abierta_porcentaje VARCHAR(20),
    area_abierta_mm VARCHAR(50),
    perforaciones VARCHAR(100),

    -- Materiales y resistencias
    material_base VARCHAR(100),
    material_PE BOOLEAN DEFAULT FALSE,
    material_PP BOOLEAN DEFAULT FALSE,
    material_POM BOOLEAN DEFAULT FALSE,
    material_PVC BOOLEAN DEFAULT FALSE,
    material_PU BOOLEAN DEFAULT FALSE,
    material_otros VARCHAR(200),

    -- Capacidades de carga (tiradores de correa)
    tirador_correa_PE DECIMAL(10,2),
    tirador_correa_PP DECIMAL(10,2),
    tirador_correa_POM DECIMAL(10,2),
    carga_trabajo_max DECIMAL(10,2),
    tension_maxima DECIMAL(10,2),

    -- Temperaturas de operación
    temperatura_min DECIMAL(6,2),
    temperatura_max DECIMAL(6,2),
    temperatura_continua_max DECIMAL(6,2),

    -- Características físicas adicionales
    espesor_total DECIMAL(10,2),
    peso_kg_m2 DECIMAL(10,3),
    radio_giro_minimo DECIMAL(10,2),
    diametro_minimo_polea DECIMAL(10,2),

    -- Certificaciones y normativas
    certificado_FDA BOOLEAN DEFAULT FALSE,
    certificado_EU BOOLEAN DEFAULT FALSE,
    certificado_USDA BOOLEAN DEFAULT FALSE,
    certificado_otros VARCHAR(200),
    apto_alimentos BOOLEAN DEFAULT FALSE,
    deteccion_metales BOOLEAN DEFAULT FALSE,

    -- Aplicaciones
    aplicaciones TEXT,
    industrias_recomendadas TEXT,

    -- Datos de Rodavigo
    articulo_rodavigo VARCHAR(100),
    marca_rodavigo VARCHAR(100),
    ficha_rodavigo VARCHAR(100),
    precio_unitario DECIMAL(12,2),
    descuento_rodavigo DECIMAL(5,2),

    -- Referencias y equivalencias
    codigo_habasit VARCHAR(100),
    codigo_intralox VARCHAR(100),
    codigo_unichain VARCHAR(100),
    codigo_scanbelt VARCHAR(100),
    codigo_forbo VARCHAR(100),
    codigo_modutech VARCHAR(100),
    referencias_cruzadas TEXT,

    -- Información adicional
    imagen_url VARCHAR(500),
    ficha_tecnica_url VARCHAR(500),
    cad_url VARCHAR(500),
    video_url VARCHAR(500),
    notas TEXT,

    -- Control
    stock_minimo INTEGER DEFAULT 0,
    unidad_medida VARCHAR(20) DEFAULT 'metro',
    multiplo_venta DECIMAL(10,2) DEFAULT 1,
    lead_time_dias INTEGER,
    obsoleto BOOLEAN DEFAULT FALSE,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (id_fabricante) REFERENCES fabricantes(id_fabricante),
    FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id_subcategoria)
);

-- Crear índices para productos
CREATE INDEX idx_productos_codigo ON productos(codigo_producto);
CREATE INDEX idx_productos_fabricante ON productos(id_fabricante);
CREATE INDEX idx_productos_tipo ON productos(tipo);
CREATE INDEX idx_productos_serie ON productos(serie);
CREATE INDEX idx_productos_paso ON productos(paso_mm);

-- ========================================
-- 8. TABLA DE PRODUCTOS-PROVEEDORES
-- ========================================
CREATE TABLE productos_proveedores (
    id SERIAL PRIMARY KEY,
    id_producto INTEGER,
    id_proveedor INTEGER,
    codigo_proveedor VARCHAR(100),
    precio_lista DECIMAL(12,2),
    descuento DECIMAL(5,2),
    precio_neto DECIMAL(12,2),
    moneda VARCHAR(3) DEFAULT 'EUR',
    cantidad_minima DECIMAL(10,2),
    multiplo_pedido DECIMAL(10,2),
    tiempo_entrega_dias INTEGER,
    fecha_precio DATE,
    vigente BOOLEAN DEFAULT TRUE,
    notas TEXT,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

CREATE INDEX idx_producto_proveedor ON productos_proveedores(id_producto, id_proveedor);

-- ========================================
-- 9. TABLA DE INVENTARIO
-- ========================================
CREATE TABLE inventario (
    id_inventario SERIAL PRIMARY KEY,
    id_producto INTEGER,
    almacen VARCHAR(50) DEFAULT 'Principal',
    ubicacion VARCHAR(50),
    cantidad_disponible DECIMAL(12,2) DEFAULT 0,
    cantidad_reservada DECIMAL(12,2) DEFAULT 0,
    cantidad_transito DECIMAL(12,2) DEFAULT 0,
    fecha_ultimo_movimiento TIMESTAMP,
    fecha_ultimo_inventario DATE,
    notas TEXT,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE INDEX idx_inventario_producto_almacen ON inventario(id_producto, almacen);

-- ========================================
-- 10. TABLA DE HISTORIAL DE PRECIOS
-- ========================================
CREATE TABLE historial_precios (
    id_historial SERIAL PRIMARY KEY,
    id_producto INTEGER,
    id_proveedor INTEGER,
    precio_anterior DECIMAL(12,2),
    precio_nuevo DECIMAL(12,2),
    porcentaje_cambio DECIMAL(6,2),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(50),
    motivo VARCHAR(200),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

-- ========================================
-- 11. TABLA DE EQUIVALENCIAS DE PRODUCTOS
-- ========================================
-- Crear tipo ENUM para tipo_equivalencia
CREATE TYPE tipo_equivalencia_enum AS ENUM ('exacta', 'similar', 'alternativa');

CREATE TABLE equivalencias_productos (
    id_equivalencia SERIAL PRIMARY KEY,
    id_producto_principal INTEGER,
    id_producto_equivalente INTEGER,
    tipo_equivalencia tipo_equivalencia_enum DEFAULT 'similar',
    porcentaje_compatibilidad INTEGER,
    notas TEXT,
    verificado BOOLEAN DEFAULT FALSE,
    fecha_verificacion DATE,
    FOREIGN KEY (id_producto_principal) REFERENCES productos(id_producto),
    FOREIGN KEY (id_producto_equivalente) REFERENCES productos(id_producto)
);

-- ========================================
-- FUNCIÓN PARA ACTUALIZAR FECHA_ACTUALIZACION
-- ========================================
CREATE OR REPLACE FUNCTION actualizar_fecha_actualizacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar fecha_actualizacion en productos
CREATE TRIGGER trigger_productos_fecha_actualizacion
    BEFORE UPDATE ON productos
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_fecha_actualizacion();

-- ========================================
-- INSERCIÓN DE DATOS INICIALES
-- ========================================

-- Insertar Fabricantes principales
INSERT INTO fabricantes (nombre, pais, sitio_web) VALUES
('Ammeraal Belts', 'Países Bajos', 'https://www.ammeraalbeltech.com'),
('Uni Chains', 'Italia', 'https://www.unichains.com'),
('AVE', 'España', 'https://www.ave.es'),
('Habasit', 'Suiza', 'https://www.habasit.com'),
('Chiorino', 'Italia', 'https://www.chiorino.com'),
('Intralox', 'Estados Unidos', 'https://www.intralox.com'),
('EUROBELT', 'España', 'https://www.eurobelt.es'),
('HONG''S BELT', 'China', 'https://www.hongsbelt.com'),
('Modutech', 'España', 'https://www.modutech.es'),
('Scanbelt', 'Dinamarca', 'https://www.scanbelt.com'),
('Mafdel', 'Francia', 'https://www.mafdel.com'),
('Esbelt', 'España', 'https://www.esbelt.com'),
('Rigalli', 'Argentina', 'https://www.rigalli.com'),
('Reveyron', 'Francia', 'https://www.reveyron.com'),
('PCS Belts', 'España', NULL),
('Indubanda', 'España', 'https://www.indubanda.com'),
('Forbo Movement Systems', 'Suiza', 'https://www.forbo.com/movement'),
('System Plast', 'Italia', 'https://www.systemplast.com');

-- Insertar Distribuidores
INSERT INTO distribuidores (nombre, pais, region) VALUES
('Jhernando', 'España', 'Nacional'),
('Campodron', 'España', 'Nacional'),
('Fredriksons (XANO)', 'Suecia', 'Europa'),
('Rodavigo', 'España', 'Nacional'),
('TecnoBelts', 'España', 'Nacional');

-- Insertar Categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Bandas Modulares', 'Bandas de plástico modular para transporte'),
('Bandas Sintéticas', 'Bandas de material sintético (PU, PVC)'),
('Bandas de Charnela', 'Bandas con sistema de charnela'),
('Bandas Transportadoras', 'Bandas para sistemas de transporte general'),
('Accesorios', 'Accesorios y componentes para bandas');

-- Insertar Subcategorías
INSERT INTO subcategorias (id_categoria, nombre, descripcion) VALUES
(1, 'Paso 6.25mm', 'Bandas modulares con paso de 6.25mm'),
(1, 'Paso 12.5mm', 'Bandas modulares con paso de 12.5mm'),
(1, 'Paso 25mm', 'Bandas modulares con paso de 25mm'),
(1, 'Paso 25.4mm', 'Bandas modulares con paso de 25.4mm (1 pulgada)'),
(1, 'Paso 38.1mm', 'Bandas modulares con paso de 38.1mm (1.5 pulgadas)'),
(1, 'Paso 50.8mm', 'Bandas modulares con paso de 50.8mm (2 pulgadas)'),
(2, 'Bandas PU', 'Bandas de poliuretano'),
(2, 'Bandas PVC', 'Bandas de PVC'),
(3, 'Charnela Plástica', 'Bandas de charnela de plástico'),
(3, 'Charnela Metálica', 'Bandas de charnela metálica');

-- Insertar algunos productos de ejemplo de Scanbelt
INSERT INTO productos (
    id_fabricante, id_subcategoria, codigo_producto, nombre, tipo,
    paso_nominal, superficie_correa, area_abierta_porcentaje, area_abierta_mm,
    tirador_correa_PE, tirador_correa_PP, tirador_correa_POM,
    material_PE, material_PP, material_POM
) VALUES
-- Productos Scanbelt
(10, 3, 'S.25-801', 'Scanbelt S.25-801', 'S.25-801', '25 milímetros', 'Abierto, suave', '41%', '10 x 5', 550, 650, NULL, TRUE, TRUE, FALSE),
(10, 1, 'S.06-401', 'Scanbelt S.06-401', 'S.06-401', '6,25 milímetros', 'Abierto', '40%', '5×10', NULL, NULL, NULL, FALSE, FALSE, FALSE),
(10, 2, 'S.12-401', 'Scanbelt S.12-401', 'S.12-401', '12,5 milímetros', 'Abierto, suave', '40%', '6×8', 600, 800, NULL, TRUE, TRUE, FALSE),
(10, 2, 'S.12-406', 'Scanbelt S.12-406', 'S.12-406', '12,5 milímetros', 'Parte superior plana perforada', NULL, NULL, NULL, NULL, NULL, FALSE, FALSE, FALSE),
(10, 2, 'S.12-408', 'Scanbelt S.12-408', 'S.12-408', '12,5 milímetros', 'Parte superior plana cerrada', 'cerrado', 'cerrado', 600, 800, 1450, TRUE, TRUE, TRUE),
(10, 2, 'S.12-408F', 'Scanbelt S.12-408F', 'S.12-408F', '12,5 milímetros', 'Superficie de fricción', 'cerrado', 'cerrado', 600, 800, 1450, TRUE, TRUE, TRUE),
(10, 2, 'S.12-438', 'Scanbelt S.12-438', 'S.12-438', '12,5 milímetros', 'Estructura superior con protuberancias de 2 mm', NULL, NULL, NULL, NULL, NULL, FALSE, FALSE, FALSE),
(10, 2, 'S.12-448', 'Scanbelt S.12-448', 'S.12-448', '12,5 milímetros', 'Parte superior de diamante invertido', NULL, NULL, NULL, NULL, NULL, FALSE, FALSE, FALSE);

-- Insertar algunos productos de Habasit (ejemplo de Rodavigo)
INSERT INTO productos (
    id_fabricante, id_subcategoria, codigo_producto, nombre,
    articulo_rodavigo, marca_rodavigo, grupo, familia,
    precio_unitario
) VALUES
(4, 7, '348HNB8E14HIGHDUTY60A', 'Correa HNB-8E 14 High Duty', '348HNB8E14HIGHDUTY60A', 'HABASIT', NULL, 'Banda PU', NULL),
(4, 7, 'HNB-8E-14', 'HNB-8E 14 Standard', NULL, 'HABASIT', NULL, 'Banda PU', NULL);

-- Insertar algunos productos de Chiorino
INSERT INTO productos (
    id_fabricante, id_subcategoria, codigo_producto, nombre,
    articulo_rodavigo, marca_rodavigo, familia, precio_unitario
) VALUES
(5, 7, '2M5-U0-U2-HP-W', 'Banda 2M5 U0-U2 HP White', '0712M5U0U24374450', 'CHIORINO', 'Banda PU', 196.55),
(5, 7, '2M8-U0-V-U0', 'Banda 2M8 U0-V-U0', '0712M8U0VU0201550SF', 'CHIORINO', 'Banda PU', NULL);

-- Insertar productos Hong's Belt (series)
INSERT INTO productos (
    id_fabricante, id_subcategoria, codigo_producto, nombre, serie, paso_mm
) VALUES
(8, 6, 'HS-100A', 'Hong''s Belt HS-100A', 'HS-100', 50.8),
(8, 4, 'HS-200A', 'Hong''s Belt HS-200A', 'HS-200', 25.4),
(8, 4, 'HS-500A-N', 'Hong''s Belt HS-500A-N', 'HS-500', 25.4),
(8, 4, 'HS-600B', 'Hong''s Belt HS-600B', 'HS-600', 25.4),
(8, 6, 'HS-800-1C', 'Hong''s Belt HS-800-1C', 'HS-800', 50.8),
(8, 5, 'HS-6800', 'Hong''s Belt Serie HS-6800', 'HS-6800', 38.1);

-- Insertar equivalencias Modutech
INSERT INTO productos (
    id_fabricante, id_subcategoria, codigo_producto, nombre,
    codigo_modutech, codigo_habasit, codigo_intralox, codigo_scanbelt, codigo_forbo
) VALUES
(9, 2, 'MP80-C', 'Modutech MP80 C', 'MP80 C', NULL, NULL, NULL, NULL),
(9, 2, 'MP80-FG', 'Modutech MP80 FG', 'MP80 FG', NULL, NULL, NULL, NULL);

-- Insertar relaciones de proveedores
INSERT INTO proveedores (id_fabricante, id_distribuidor, nombre_comercial) VALUES
(2, 1, 'Uni Chains'),
(8, 2, 'Hong'),
(12, 3, 'Esbelt '),
(4, 4, 'Habasit'),
(5, 4, 'Chiorino');

-- ========================================
-- VISTAS ÚTILES
-- ========================================

-- Vista de productos con información completa
CREATE VIEW v_productos_completo AS
SELECT
    p.id_producto,
    p.codigo_producto,
    p.nombre AS nombre_producto,
    f.nombre AS fabricante,
    c.nombre AS categoria,
    sc.nombre AS subcategoria,
    p.tipo,
    p.serie,
    p.paso_nominal,
    p.paso_mm,
    p.superficie_correa,
    p.area_abierta_porcentaje,
    p.area_abierta_mm,
    p.material_base,
    CASE
        WHEN p.material_PE THEN 'PE '
        ELSE ''
    END ||
    CASE
        WHEN p.material_PP THEN 'PP '
        ELSE ''
    END ||
    CASE
        WHEN p.material_POM THEN 'POM '
        ELSE ''
    END AS materiales_disponibles,
    p.tirador_correa_PE,
    p.tirador_correa_PP,
    p.tirador_correa_POM,
    p.temperatura_min,
    p.temperatura_max,
    p.apto_alimentos,
    p.precio_unitario,
    p.activo
FROM productos p
LEFT JOIN fabricantes f ON p.id_fabricante = f.id_fabricante
LEFT JOIN subcategorias sc ON p.id_subcategoria = sc.id_subcategoria
LEFT JOIN categorias c ON sc.id_categoria = c.id_categoria;

-- Vista de equivalencias entre marcas
CREATE VIEW v_equivalencias_marcas AS
SELECT
    p.codigo_producto AS codigo_principal,
    f.nombre AS marca_principal,
    p.codigo_habasit,
    p.codigo_intralox,
    p.codigo_unichain,
    p.codigo_scanbelt,
    p.codigo_forbo,
    p.codigo_modutech
FROM productos p
JOIN fabricantes f ON p.id_fabricante = f.id_fabricante
WHERE p.codigo_habasit IS NOT NULL
   OR p.codigo_intralox IS NOT NULL
   OR p.codigo_unichain IS NOT NULL
   OR p.codigo_scanbelt IS NOT NULL
   OR p.codigo_forbo IS NOT NULL
   OR p.codigo_modutech IS NOT NULL;

-- Vista de productos con stock
CREATE VIEW v_productos_inventario AS
SELECT
    p.codigo_producto,
    p.nombre AS producto,
    f.nombre AS fabricante,
    COALESCE(i.cantidad_disponible, 0) AS stock_disponible,
    COALESCE(i.cantidad_reservada, 0) AS stock_reservado,
    COALESCE(i.cantidad_transito, 0) AS stock_transito,
    (COALESCE(i.cantidad_disponible, 0) - COALESCE(i.cantidad_reservada, 0)) AS stock_libre,
    p.stock_minimo,
    CASE
        WHEN (COALESCE(i.cantidad_disponible, 0) - COALESCE(i.cantidad_reservada, 0)) < p.stock_minimo
        THEN 'REORDENAR'
        ELSE 'OK'
    END AS estado_stock,
    i.almacen,
    i.ubicacion
FROM productos p
LEFT JOIN inventario i ON p.id_producto = i.id_producto
LEFT JOIN fabricantes f ON p.id_fabricante = f.id_fabricante
WHERE p.activo = TRUE;

-- Vista de productos por paso/pitch
CREATE VIEW v_productos_por_paso AS
SELECT
    p.paso_mm,
    p.paso_nominal,
    COUNT(*) AS cantidad_productos,
    STRING_AGG(DISTINCT f.nombre, ', ') AS fabricantes,
    STRING_AGG(DISTINCT p.superficie_correa, ', ') AS tipos_superficie
FROM productos p
LEFT JOIN fabricantes f ON p.id_fabricante = f.id_fabricante
WHERE p.paso_mm IS NOT NULL
GROUP BY p.paso_mm, p.paso_nominal
ORDER BY p.paso_mm;

-- ========================================
-- FUNCIONES (PROCEDIMIENTOS ALMACENADOS EN POSTGRESQL)
-- ========================================

-- Función para buscar productos equivalentes
CREATE OR REPLACE FUNCTION sp_buscar_equivalentes(p_codigo_producto VARCHAR(100))
RETURNS TABLE(
    codigo_producto VARCHAR(100),
    nombre VARCHAR(255),
    fabricante VARCHAR(100),
    tipo_relacion VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p2.codigo_producto,
        p2.nombre,
        f.nombre AS fabricante,
        'Código cruzado'::VARCHAR(50) AS tipo_relacion
    FROM productos p1
    JOIN productos p2 ON (
        (p1.codigo_habasit IS NOT NULL AND p1.codigo_habasit = p2.codigo_habasit) OR
        (p1.codigo_intralox IS NOT NULL AND p1.codigo_intralox = p2.codigo_intralox) OR
        (p1.codigo_unichain IS NOT NULL AND p1.codigo_unichain = p2.codigo_unichain) OR
        (p1.codigo_scanbelt IS NOT NULL AND p1.codigo_scanbelt = p2.codigo_scanbelt) OR
        (p1.codigo_forbo IS NOT NULL AND p1.codigo_forbo = p2.codigo_forbo) OR
        (p1.codigo_modutech IS NOT NULL AND p1.codigo_modutech = p2.codigo_modutech)
    )
    JOIN fabricantes f ON p2.id_fabricante = f.id_fabricante
    WHERE p1.codigo_producto = p_codigo_producto
      AND p1.id_producto != p2.id_producto

    UNION

    SELECT
        p2.codigo_producto,
        p2.nombre,
        f.nombre AS fabricante,
        ep.tipo_equivalencia::VARCHAR(50) AS tipo_relacion
    FROM productos p1
    JOIN equivalencias_productos ep ON p1.id_producto = ep.id_producto_principal
    JOIN productos p2 ON ep.id_producto_equivalente = p2.id_producto
    JOIN fabricantes f ON p2.id_fabricante = f.id_fabricante
    WHERE p1.codigo_producto = p_codigo_producto;
END;
$$ LANGUAGE plpgsql;

-- Función para actualizar precio con historial
CREATE OR REPLACE FUNCTION sp_actualizar_precio(
    p_id_producto INTEGER,
    p_id_proveedor INTEGER,
    p_precio_nuevo DECIMAL(12,2),
    p_usuario VARCHAR(50),
    p_motivo VARCHAR(200)
)
RETURNS VOID AS $$
DECLARE
    v_precio_anterior DECIMAL(12,2);
    v_porcentaje_cambio DECIMAL(6,2);
BEGIN
    -- Obtener precio anterior
    SELECT precio_neto INTO v_precio_anterior
    FROM productos_proveedores
    WHERE id_producto = p_id_producto
      AND id_proveedor = p_id_proveedor
      AND vigente = TRUE
    LIMIT 1;

    -- Calcular porcentaje de cambio
    IF v_precio_anterior IS NOT NULL AND v_precio_anterior > 0 THEN
        v_porcentaje_cambio := ((p_precio_nuevo - v_precio_anterior) / v_precio_anterior) * 100;
    ELSE
        v_porcentaje_cambio := 0;
    END IF;

    -- Insertar en historial
    INSERT INTO historial_precios (
        id_producto, id_proveedor, precio_anterior,
        precio_nuevo, porcentaje_cambio, usuario, motivo
    ) VALUES (
        p_id_producto, p_id_proveedor, v_precio_anterior,
        p_precio_nuevo, v_porcentaje_cambio, p_usuario, p_motivo
    );

    -- Actualizar precio actual
    UPDATE productos_proveedores
    SET precio_neto = p_precio_nuevo,
        fecha_precio = CURRENT_DATE
    WHERE id_producto = p_id_producto
      AND id_proveedor = p_id_proveedor
      AND vigente = TRUE;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- ========================================

CREATE INDEX idx_productos_fabricante_tipo ON productos(id_fabricante, tipo);
CREATE INDEX idx_productos_material ON productos(material_base);
CREATE INDEX idx_productos_apto_alimentos ON productos(apto_alimentos);
CREATE INDEX idx_productos_temperatura ON productos(temperatura_min, temperatura_max);
CREATE INDEX idx_productos_referencias ON productos(codigo_habasit, codigo_intralox, codigo_modutech);
CREATE INDEX idx_inventario_stock ON inventario(cantidad_disponible, cantidad_reservada);
CREATE INDEX idx_precios_fecha ON historial_precios(fecha_cambio);

-- ========================================
-- COMENTARIOS DE TABLAS
-- ========================================

COMMENT ON TABLE fabricantes IS 'Catálogo de fabricantes de bandas modulares y transportadoras';
COMMENT ON TABLE distribuidores IS 'Distribuidores oficiales por región';
COMMENT ON TABLE productos IS 'Catálogo completo de productos con especificaciones técnicas extendidas';
COMMENT ON TABLE equivalencias_productos IS 'Tabla de equivalencias y compatibilidades entre productos';
COMMENT ON TABLE inventario IS 'Control de inventario por almacén y ubicación';
COMMENT ON TABLE historial_precios IS 'Registro histórico de cambios de precios';

