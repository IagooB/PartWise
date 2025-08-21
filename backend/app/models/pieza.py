



# models/pieza.py
from sqlalchemy import Column, Integer, String, Text, Float, Boolean, ForeignKey, DateTime, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Pieza(Base):
    __tablename__ = "piezas"

    id = Column(Integer, primary_key=True, index=True)
    codigo = Column(String(100), unique=True, nullable=False, index=True)
    nombre = Column(String(200), nullable=False, index=True)
    descripcion = Column(Text)

    # Relaciones
    categoria_id = Column(Integer, ForeignKey("categorias.id"))
    proveedor_id = Column(Integer, ForeignKey("proveedores.id"))

    # Características técnicas (JSON para flexibilidad)
    especificaciones = Column(JSON, default={})
    # Ejemplo: {"material": "acero", "ancho": "500mm", "longitud": "1000mm"}

    # Medidas principales
    largo = Column(Float)
    ancho = Column(Float)
    alto = Column(Float)
    peso = Column(Float)
    unidad_medida = Column(String(20), default="mm")

    # Estado y disponibilidad
    activo = Column(Boolean, default=True)
    stock = Column(Integer, default=0)
    stock_minimo = Column(Integer, default=0)
    ubicacion_almacen = Column(String(100))

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relaciones
    categoria = relationship("Categoria", backref="piezas")
    proveedor = relationship("Proveedor", backref="piezas")
    imagenes = relationship("ImagenPieza", back_populates="pieza", cascade="all, delete-orphan")


# models/imagen.py
from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class ImagenPieza(Base):
    __tablename__ = "imagenes_piezas"

    id = Column(Integer, primary_key=True, index=True)
    pieza_id = Column(Integer, ForeignKey("piezas.id"), nullable=False)
    filename = Column(String(255), nullable=False)
    filepath = Column(String(500), nullable=False)
    es_principal = Column(Boolean, default=False)
    descripcion = Column(String(200))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    pieza = relationship("Pieza", back_populates="imagenes")