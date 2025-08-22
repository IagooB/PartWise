# backend/app/models/models.py
"""
Modelos SQLAlchemy simplificados para el sistema PartWise
Sincronizados con la estructura de base de datos PostgreSQL
"""

from sqlalchemy import (
    Column, String, Boolean, Float, Integer, Text,
    ForeignKey, DateTime, ARRAY, JSON, DECIMAL,
    UniqueConstraint, CheckConstraint
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from app.database import Base


# ============================================
# MODELO: Fabricantes
# ============================================
class Fabricante(Base):
    __tablename__ = "fabricantes"
    __table_args__ = {'schema': 'partwise'}

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nombre = Column(String(200), nullable=False, unique=True, index=True)
    sitio_web = Column(String(255))
    email = Column(String(100))
    familias_productos = Column(ARRAY(Text))  # Array de strings
    activo = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relaciones
    productos = relationship("Producto", back_populates="fabricante")


# ============================================
# MODELO: Proveedores
# ============================================
class Proveedor(Base):
    __tablename__ = "proveedores"
    __table_args__ = {'schema': 'partwise'}

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nombre = Column(String(200), nullable=False, unique=True, index=True)
    sitio_web = Column(String(255))
    email = Column(String(100))
    activo = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relaciones
    productos_proveedores = relationship("ProductoProveedor", back_populates="proveedor")


# ============================================
# MODELO: Familias de Productos
# ============================================
class FamiliaProducto(Base):
    __tablename__ = "familias_productos"
    __table_args__ = {'schema': 'partwise'}

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    codigo = Column(String(50), unique=True, nullable=False, index=True)
    nombre = Column(String(100), nullable=False)
    descripcion = Column(Text)
    orden = Column(Integer, default=0)
    activo = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relaciones
    productos = relationship("Producto", back_populates="familia")


# ============================================
# MODELO: Productos
# ============================================
class Producto(Base):
    __tablename__ = "productos"
    __table_args__ = (
        UniqueConstraint('fabricante_id', 'serie', 'modelo',
                         name='uk_producto_fabricante_serie_modelo'),
        {'schema': 'partwise'}
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    # Relaciones
    fabricante_id = Column(UUID(as_uuid=True), ForeignKey('partwise.fabricantes.id'))
    familia_id = Column(UUID(as_uuid=True), ForeignKey('partwise.familias_productos.id'))

    # Identificación
    serie = Column(String(100))
    modelo = Column(String(100), nullable=False)
    codigo_interno = Column(String(100), unique=True, index=True)

    # Características flexibles en JSONB
    caracteristicas = Column(JSON, default={})

    # Metadatos
    notas = Column(Text)
    obsoleto = Column(Boolean, default=False)
    activo = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relaciones
    fabricante = relationship("Fabricante", back_populates="productos")
    familia = relationship("FamiliaProducto", back_populates="productos")
    productos_proveedores = relationship("ProductoProveedor", back_populates="producto")
    inventario = relationship("Inventario", back_populates="producto", uselist=False)
    documentos = relationship("Documento", back_populates="producto")


# ============================================
# MODELO: Productos-Proveedores (N:M)
# ============================================
class ProductoProveedor(Base):
    __tablename__ = "productos_proveedores"
    __table_args__ = (
        UniqueConstraint('producto_id', 'proveedor_id',
                         name='uk_producto_proveedor'),
        {'schema': 'partwise'}
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    producto_id = Column(UUID(as_uuid=True), ForeignKey('partwise.productos.id'))
    proveedor_id = Column(UUID(as_uuid=True), ForeignKey('partwise.proveedores.id'))

    codigo_proveedor = Column(String(100))
    precio_lista = Column(DECIMAL(12, 2))
    moneda = Column(String(3), default='EUR')
    disponible = Column(Boolean, default=True)
    tiempo_entrega_dias = Column(Integer)
    url_producto = Column(String(500))
    notas = Column(Text)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relaciones
    producto = relationship("Producto", back_populates="productos_proveedores")
    proveedor = relationship("Proveedor", back_populates="productos_proveedores")


# ============================================
# MODELO: Inventario
# ============================================
class Inventario(Base):
    __tablename__ = "inventario"
    __table_args__ = (
        UniqueConstraint('producto_id', name='uk_inventario_producto'),
        {'schema': 'partwise'}
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    producto_id = Column(UUID(as_uuid=True), ForeignKey('partwise.productos.id'))

    cantidad = Column(DECIMAL(12, 2), default=0)
    ubicacion = Column(String(50))
    stock_minimo = Column(DECIMAL(12, 2), default=0)
    notas = Column(Text)
    ultima_actualizacion = Column(DateTime(timezone=True), server_default=func.now())

    # Relaciones
    producto = relationship("Producto", back_populates="inventario")


# ============================================
# MODELO: Documentos
# ============================================
class Documento(Base):
    __tablename__ = "documentos"
    __table_args__ = {'schema': 'partwise'}

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    producto_id = Column(UUID(as_uuid=True), ForeignKey('partwise.productos.id'))

    tipo = Column(String(50))  # 'ficha_tecnica', 'manual', 'certificado'
    nombre_archivo = Column(String(255), nullable=False)
    ruta_archivo = Column(String(500))
    url_externa = Column(String(500))
    descripcion = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relaciones
    producto = relationship("Producto", back_populates="documentos")