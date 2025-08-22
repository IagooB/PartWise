-- ========================================
-- BASE DE DATOS PARA PARTWISE (DB_BELTS)
-- Versión 3.0 - Estructura con JSONB y sin inventario
-- ========================================

-- Eliminar tablas si existen para una inicialización limpia
DROP TABLE IF EXISTS equivalencias_productos CASCADE;
DROP TABLE IF EXISTS historial_precios CASCADE;
DROP TABLE IF EXISTS productos_proveedores CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS subcategorias CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS contactos_proveedores CASCADE;
DROP TABLE IF EXISTS proveedores CASCADE;
DROP TABLE IF EXISTS distribuidores CASCADE;
DROP TABLE IF EXISTS fabricantes CASCADE;

-- ========================================
-- 1. TABLA DE FABRICANTES
-- ========================================
CREATE TABLE fabricantes (
    id_fabricante SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais VARCHAR(50),
    sitio_web VARCHAR(255),
    notas TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- ========================================
-- 2. TABLA DE PROVEEDORES
-- ========================================
CREATE TABLE proveedores (
    id_proveedor SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    codigo VARCHAR(50) UNIQUE,
    telefono VARCHAR(50),
    email VARCHAR(100),
    direccion TEXT,
    sitio_web VARCHAR(200),
    notas TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- ========================================
-- 3. TABLA DE CATEGORÍAS
-- ========================================
CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- ========================================
-- 4. TABLA DE SUBCATEGORÍAS
-- ========================================
CREATE TABLE subcategorias (
    id_subcategoria SERIAL PRIMARY KEY,
    id_categoria INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- ========================================
-- 5. TABLA DE PRODUCTOS
-- ========================================
CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    id_fabricante INTEGER,
    id_subcategoria INTEGER,
    codigo_producto VARCHAR(100) NOT NULL UNIQUE,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    -- Columna flexible para especificaciones variables
    caracteristicas JSONB,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_fabricante) REFERENCES fabricantes(id_fabricante),
    FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id_subcategoria)
);

-- Crear un índice GIN en el campo JSONB para búsquedas eficientes
CREATE INDEX idx_productos_caracteristicas ON productos USING GIN (caracteristicas);


-- ========================================
-- 6. TABLA DE PRODUCTOS-PROVEEDORES (Precios y condiciones)
-- ========================================
CREATE TABLE productos_proveedores (
    id SERIAL PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    id_proveedor INTEGER NOT NULL,
    precio_lista DECIMAL(12, 2),
    descuento DECIMAL(5, 2),
    moneda VARCHAR(3) DEFAULT 'EUR',
    tiempo_entrega_dias INTEGER,
    vigente BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

-- ========================================
-- INSERCIÓN DE DATOS INICIALES
-- ========================================

-- Fabricantes
INSERT INTO fabricantes (nombre, pais, sitio_web) VALUES
('Habasit', 'Suiza', 'https://www.habasit.com'),
('Intralox', 'Estados Unidos', 'https://www.intralox.com'),
('Scanbelt', 'Dinamarca', 'https://www.scanbelt.com'),
('Ammeraal Beltech', 'Países Bajos', 'https://www.ammeraalbeltech.com');

-- Proveedores
INSERT INTO proveedores (nombre, codigo, telefono, email, sitio_web) VALUES
('Rodavigo', 'PROV001', '+34 986 45 46 22', 'info@rodavigo.com', 'www.rodavigo.com'),
('TecnoBelts', 'PROV002', '+34 93 123 4567', 'info@tecnobelts.es', 'www.tecnobelts.es');

-- Categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Bandas Modulares', 'Bandas de plástico modular para transporte'),
('Bandas Sintéticas', 'Bandas de material sintético (PU, PVC)'),
('Bandas de Goma', 'Bandas de caucho para aplicaciones industriales'),
('Bandas Metálicas', 'Bandas de acero para alta resistencia y temperatura');

-- Subcategorías
INSERT INTO subcategorias (id_categoria, nombre, descripcion) VALUES
(1, 'Paso 25.4mm (1")', 'Bandas modulares con paso de 1 pulgada'),
(1, 'Paso 50.8mm (2")', 'Bandas modulares con paso de 2 pulgadas'),
(2, 'Bandas de PU', 'Bandas de poliuretano, aptas para alimentación'),
(2, 'Bandas de PVC', 'Bandas de PVC, uso general');

-- Productos de ejemplo con características en JSONB
INSERT INTO productos (id_fabricante, id_subcategoria, codigo_producto, nombre, caracteristicas) VALUES
(
    1, 1, 'Haba-M2540-Flat', 'Banda Habasit M2540 Flat Top',
    '{
        "paso_mm": 25.4,
        "material_base": "POM",
        "apto_alimentos": true,
        "temperatura_min": -40,
        "temperatura_max": 90,
        "superficie": "Plana (Flat Top)",
        "color": "Blanco"
    }'
),
(
    2, 1, 'Intra-S900-Flat', 'Banda Intralox Serie 900 Flat Top',
    '{
        "paso_mm": 25.4,
        "material_base": "PE",
        "apto_alimentos": true,
        "temperatura_max": 65,
        "superficie": "Plana (Flat Top)",
        "facil_limpieza": true,
        "color": "Azul"
    }'
),
(
    3, 2, 'Scan-S50-Mesh', 'Banda Scanbelt S50 Open Mesh',
    '{
        "paso_mm": 50.8,
        "material_base": "PP",
        "apto_alimentos": true,
        "area_abierta_pct": 40,
        "superficie": "Rejilla abierta (Open Mesh)",
        "color": "Natural"
    }'
);

-- Precios de ejemplo
INSERT INTO productos_proveedores (id_producto, id_proveedor, precio_lista, tiempo_entrega_dias) VALUES
(1, 1, 120.50, 5),
(2, 1, 135.00, 7),
(3, 2, 95.75, 3);