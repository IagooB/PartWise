# routers/categorias.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional

from app.database import get_db
from app.models.categoria import Categoria
from app.schemas.pieza import CategoriaCreate, CategoriaResponse

router = APIRouter(prefix="/api/categorias", tags=["categorias"])


@router.get("/", response_model=List[CategoriaResponse])
def listar_categorias(
        skip: int = 0,
        limit: int = 100,
        db: Session = Depends(get_db)
):
    """Listar todas las categorías"""
    categorias = db.query(Categoria).offset(skip).limit(limit).all()
    return categorias


@router.get("/{categoria_id}", response_model=CategoriaResponse)
def obtener_categoria(categoria_id: int, db: Session = Depends(get_db)):
    """Obtener una categoría específica"""
    categoria = db.query(Categoria).filter(Categoria.id == categoria_id).first()
    if not categoria:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")
    return categoria


@router.post("/", response_model=CategoriaResponse)
def crear_categoria(categoria: CategoriaCreate, db: Session = Depends(get_db)):
    """Crear una nueva categoría"""
    # Verificar que el nombre no exista
    if db.query(Categoria).filter(Categoria.nombre == categoria.nombre).first():
        raise HTTPException(status_code=400, detail="La categoría ya existe")

    # Verificar código único si se proporciona
    if categoria.codigo:
        if db.query(Categoria).filter(Categoria.codigo == categoria.codigo).first():
            raise HTTPException(status_code=400, detail="El código ya existe")

    db_categoria = Categoria(**categoria.dict())
    db.add(db_categoria)
    db.commit()
    db.refresh(db_categoria)
    return db_categoria


@router.put("/{categoria_id}", response_model=CategoriaResponse)
def actualizar_categoria(
        categoria_id: int,
        categoria: CategoriaCreate,
        db: Session = Depends(get_db)
):
    """Actualizar una categoría"""
    db_categoria = db.query(Categoria).filter(Categoria.id == categoria_id).first()
    if not db_categoria:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")

    for key, value in categoria.dict().items():
        setattr(db_categoria, key, value)

    db.commit()
    db.refresh(db_categoria)
    return db_categoria


@router.delete("/{categoria_id}")
def eliminar_categoria(categoria_id: int, db: Session = Depends(get_db)):
    """Eliminar una categoría"""
    categoria = db.query(Categoria).filter(Categoria.id == categoria_id).first()
    if not categoria:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")

    # Verificar si hay piezas asociadas
    from app.models.pieza import Pieza
    if db.query(Pieza).filter(Pieza.categoria_id == categoria_id).first():
        raise HTTPException(
            status_code=400,
            detail="No se puede eliminar la categoría porque tiene piezas asociadas"
        )

    db.delete(categoria)
    db.commit()
    return {"message": "Categoría eliminada exitosamente"}