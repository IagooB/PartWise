-- ========================================
-- BASE DE DATOS SIMPLIFICADA PARA PARTWISE
-- Versión 1.0 - Estructura esencial - PostgreSQL
-- ========================================

-- Eliminar tablas si existen (en orden inverso por las claves foráneas)
DROP TABLE IF EXISTS inventario CASCADE;
DROP TABLE IF EXISTS productos_proveedores CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS subcategorias CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS proveedores CASCADE;
DROP TABLE IF EXISTS fabricantes CASCADE;


-- ========================================
-- 1. TABLA DE FABRICANTES
-- ========================================
CREATE TABLE fabricantes (
    id_fabricante SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    pais VARCHAR(50),
    sitio_web VARCHAR(255),
    notas TEXT
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
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE
);

-- ========================================
-- 4. TABLA DE SUBCATEGORÍAS
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
-- 5. TABLA DE PRODUCTOS
-- ========================================
-- Ejemplo de cómo sería la tabla productos
CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    id_fabricante INTEGER,
    id_subcategoria INTEGER,
    codigo_producto VARCHAR(100) NOT NULL UNIQUE,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    paso_mm DECIMAL(10,2),
    material_base VARCHAR(100),
    temperatura_min DECIMAL(6,2),
    temperatura_max DECIMAL(6,2),
    apto_alimentos BOOLEAN DEFAULT FALSE,
    -- Columna flexible para especificaciones
    especificaciones JSONB,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_fabricante) REFERENCES fabricantes(id_fabricante),
    FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id_subcategoria)
);

-- ========================================
-- 6. TABLA DE PRODUCTOS-PROVEEDORES
-- ========================================
CREATE TABLE productos_proveedores (
    id SERIAL PRIMARY KEY,
    id_producto INTEGER,
    id_proveedor INTEGER,
    precio DECIMAL(12,2),
    vigente BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

-- ========================================
-- 7. TABLA DE INVENTARIO
-- ========================================
CREATE TABLE inventario (
    id_inventario SERIAL PRIMARY KEY,
    id_producto INTEGER,
    almacen VARCHAR(50) DEFAULT 'Principal',
    ubicacion VARCHAR(50),
    cantidad_disponible DECIMAL(12,2) DEFAULT 0,
    cantidad_reservada DECIMAL(12,2) DEFAULT 0,
    fecha_ultimo_movimiento TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- ========================================
-- INSERCIÓN DE DATOS INICIALES
-- ========================================

-- Insertar Fabricantes principales
INSERT INTO fabricantes (nombre, pais, sitio_web) VALUES
('Habasit', 'Suiza', 'https://www.habasit.com'),
('Intralox', 'Estados Unidos', 'https://www.intralox.com'),
('Scanbelt', 'Dinamarca', 'https://www.scanbelt.com');

-- Insertar Proveedores de ejemplo
INSERT INTO proveedores (nombre, codigo, telefono, email, sitio_web) VALUES
('Rodavigo', 'PROV001', '+34 986 45 46 22', 'info@rodavigo.com', 'www.rodavigo.com'),
('TecnoBelts', 'PROV002', '+34 93 123 4567', 'info@tecnobelts.es', 'www.tecnobelts.es');

-- Insertar Categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Bandas Modulares', 'Bandas de plástico modular para transporte'),
('Bandas Sintéticas', 'Bandas de material sintético (PU, PVC)');

-- Insertar Subcategorías
INSERT INTO subcategorias (id_categoria, nombre, descripcion) VALUES
(1, 'Paso 25.4mm', 'Bandas modulares con paso de 25.4mm'),
(1, 'Paso 50.8mm', 'Bandas modulares con paso de 50.8mm');

-- Insertar algunos productos de ejemplo
INSERT INTO productos (
    id_fabricante, id_subcategoria, codigo_producto, nombre,
    paso_mm, material_base, apto_alimentos, stock_minimo
) VALUES
(1, 1, 'Haba-25.4-Flat', 'Banda Habasit 25.4mm plana', 25.4, 'POM', TRUE, 50),
(2, 1, 'Intra-1000-FlatTop', 'Banda Intralox Serie 1000', 25.4, 'PE', TRUE, 30),
(3, 2, 'Scan-50.8-Mesh', 'Banda Scanbelt Malla 50.8mm', 50.8, 'PP', TRUE, 20);

-- Insertar stock de ejemplo
INSERT INTO inventario (id_producto, cantidad_disponible) VALUES
(1, 150),
(2, 80),
(3, 45);