# routers/proveedores.py
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from app.database import get_db
from app.models.proveedor import Proveedor
from app.schemas.pieza import ProveedorCreate, ProveedorResponse

router = APIRouter(prefix="/api/proveedores", tags=["proveedores"])


@router.get("/", response_model=List[ProveedorResponse])
def listar_proveedores(
        skip: int = 0,
        limit: int = 100,
        busqueda: Optional[str] = None,
        db: Session = Depends(get_db)
):
    """Listar todos los proveedores con búsqueda opcional"""
    query = db.query(Proveedor)

    if busqueda:
        query = query.filter(
            (Proveedor.nombre.ilike(f"%{busqueda}%")) |
            (Proveedor.codigo.ilike(f"%{busqueda}%")) |
            (Proveedor.email.ilike(f"%{busqueda}%"))
        )

    proveedores = query.offset(skip).limit(limit).all()
    return proveedores


@router.get("/{proveedor_id}", response_model=ProveedorResponse)
def obtener_proveedor(proveedor_id: int, db: Session = Depends(get_db)):
    """Obtener un proveedor específico"""
    proveedor = db.query(Proveedor).filter(Proveedor.id == proveedor_id).first()
    if not proveedor:
        raise HTTPException(status_code=404, detail="Proveedor no encontrado")
    return proveedor


@router.post("/", response_model=ProveedorResponse)
def crear_proveedor(proveedor: ProveedorCreate, db: Session = Depends(get_db)):
    """Crear un nuevo proveedor"""
    # Verificar código único si se proporciona
    if proveedor.codigo:
        if db.query(Proveedor).filter(Proveedor.codigo == proveedor.codigo).first():
            raise HTTPException(status_code=400, detail="El código de proveedor ya existe")

    db_proveedor = Proveedor(**proveedor.dict())
    db.add(db_proveedor)
    db.commit()
    db.refresh(db_proveedor)
    return db_proveedor


@router.put("/{proveedor_id}", response_model=ProveedorResponse)
def actualizar_proveedor(
        proveedor_id: int,
        proveedor: ProveedorCreate,
        db: Session = Depends(get_db)
):
    """Actualizar un proveedor"""
    db_proveedor = db.query(Proveedor).filter(Proveedor.id == proveedor_id).first()
    if not db_proveedor:
        raise HTTPException(status_code=404, detail="Proveedor no encontrado")

    for key, value in proveedor.dict().items():
        setattr(db_proveedor, key, value)

    db.commit()
    db.refresh(db_proveedor)
    return db_proveedor


@router.delete("/{proveedor_id}")
def eliminar_proveedor(proveedor_id: int, db: Session = Depends(get_db)):
    """Eliminar un proveedor"""
    proveedor = db.query(Proveedor).filter(Proveedor.id == proveedor_id).first()
    if not proveedor:
        raise HTTPException(status_code=404, detail="Proveedor no encontrado")

    # Verificar si hay piezas asociadas
    from app.models.pieza import Pieza
    if db.query(Pieza).filter(Pieza.proveedor_id == proveedor_id).first():
        raise HTTPException(
            status_code=400,
            detail="No se puede eliminar el proveedor porque tiene piezas asociadas"
        )

    db.delete(proveedor)
    db.commit()
    return {"message": "Proveedor eliminado exitosamente"}


@router.get("/{proveedor_id}/piezas")
def obtener_piezas_proveedor(
        proveedor_id: int,
        db: Session = Depends(get_db)
):
    """Obtener todas las piezas de un proveedor"""
    proveedor = db.query(Proveedor).filter(Proveedor.id == proveedor_id).first()
    if not proveedor:
        raise HTTPException(status_code=404, detail="Proveedor no encontrado")

    from app.models.pieza import Pieza
    piezas = db.query(Pieza).filter(Pieza.proveedor_id == proveedor_id).all()

    return {
        "proveedor": proveedor.nombre,
        "total_piezas": len(piezas),
        "piezas": [
            {
                "id": p.id,
                "codigo": p.codigo,
                "nombre": p.nombre,
                "stock": p.stock
            } for p in piezas
        ]
    }