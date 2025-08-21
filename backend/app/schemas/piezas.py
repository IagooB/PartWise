# schemas/pieza.py
from pydantic import BaseModel, Field
from typing import Optional, Dict, List
from datetime import datetime


# Schema base para Categoria
class CategoriaBase(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=100)
    descripcion: Optional[str] = None
    codigo: Optional[str] = Field(None, max_length=50)


class CategoriaCreate(CategoriaBase):
    pass


class CategoriaResponse(CategoriaBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True


# Schema base para Proveedor
class ProveedorBase(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=200)
    codigo: Optional[str] = Field(None, max_length=50)
    telefono: Optional[str] = None
    email: Optional[str] = None
    direccion: Optional[str] = None
    sitio_web: Optional[str] = None
    notas: Optional[str] = None


class ProveedorCreate(ProveedorBase):
    pass


class ProveedorResponse(ProveedorBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True


# Schema para Imagen
class ImagenBase(BaseModel):
    descripcion: Optional[str] = None
    es_principal: bool = False


class ImagenResponse(ImagenBase):
    id: int
    filename: str
    filepath: str
    created_at: datetime

    class Config:
        from_attributes = True


# Schema base para Pieza
class PiezaBase(BaseModel):
    codigo: str = Field(..., min_length=1, max_length=100)
    nombre: str = Field(..., min_length=1, max_length=200)
    descripcion: Optional[str] = None
    categoria_id: Optional[int] = None
    proveedor_id: Optional[int] = None
    especificaciones: Optional[Dict] = Field(default_factory=dict)
    largo: Optional[float] = None
    ancho: Optional[float] = None
    alto: Optional[float] = None
    peso: Optional[float] = None
    unidad_medida: str = Field(default="mm", max_length=20)
    activo: bool = True
    stock: int = Field(default=0, ge=0)
    stock_minimo: int = Field(default=0, ge=0)
    ubicacion_almacen: Optional[str] = None


class PiezaCreate(PiezaBase):
    pass


class PiezaUpdate(BaseModel):
    nombre: Optional[str] = None
    descripcion: Optional[str] = None
    categoria_id: Optional[int] = None
    proveedor_id: Optional[int] = None
    especificaciones: Optional[Dict] = None
    largo: Optional[float] = None
    ancho: Optional[float] = None
    alto: Optional[float] = None
    peso: Optional[float] = None
    stock: Optional[int] = None
    stock_minimo: Optional[int] = None
    ubicacion_almacen: Optional[str] = None
    activo: Optional[bool] = None


class PiezaResponse(PiezaBase):
    id: int
    categoria: Optional[CategoriaResponse] = None
    proveedor: Optional[ProveedorResponse] = None
    imagenes: List[ImagenResponse] = []
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True