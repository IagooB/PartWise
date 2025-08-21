# routers/piezas.py
from fastapi import APIRouter, Depends, HTTPException, File, UploadFile, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import shutil
from pathlib import Path
import uuid

from app.database import get_db
from app.models.pieza import Pieza, ImagenPieza
from app.models.categoria import Categoria
from app.models.proveedor import Proveedor
from app.schemas.pieza import PiezaCreate, PiezaResponse, PiezaUpdate
from app.config import settings

router = APIRouter(prefix="/api/piezas", tags=["piezas"])


@router.get("/", response_model=List[PiezaResponse])
def listar_piezas(
        skip: int = 0,
        limit: int = Query(default=100, le=1000),
        busqueda: Optional[str] = None,
        categoria_id: Optional[int] = None,
        proveedor_id: Optional[int] = None,
        activo: Optional[bool] = None,
        db: Session = Depends(get_db)
):
    """Listar todas las piezas con filtros opcionales"""
    query = db.query(Pieza)

    if busqueda:
        query = query.filter(
            (Pieza.nombre.ilike(f"%{busqueda}%")) |
            (Pieza.codigo.ilike(f"%{busqueda}%")) |
            (Pieza.descripcion.ilike(f"%{busqueda}%"))
        )

    if categoria_id:
        query = query.filter(Pieza.categoria_id == categoria_id)

    if proveedor_id:
        query = query.filter(Pieza.proveedor_id == proveedor_id)

    if activo is not None:
        query = query.filter(Pieza.activo == activo)

    piezas = query.offset(skip).limit(limit).all()
    return piezas


@router.get("/{pieza_id}", response_model=PiezaResponse)
def obtener_pieza(pieza_id: int, db: Session = Depends(get_db)):
    """Obtener una pieza específica por ID"""
    pieza = db.query(Pieza).filter(Pieza.id == pieza_id).first()
    if not pieza:
        raise HTTPException(status_code=404, detail="Pieza no encontrada")
    return pieza


@router.post("/", response_model=PiezaResponse)
def crear_pieza(pieza: PiezaCreate, db: Session = Depends(get_db)):
    """Crear una nueva pieza"""
    # Verificar que el código no exista
    if db.query(Pieza).filter(Pieza.codigo == pieza.codigo).first():
        raise HTTPException(status_code=400, detail="El código de pieza ya existe")

    # Verificar que categoria y proveedor existan si se proporcionan
    if pieza.categoria_id:
        if not db.query(Categoria).filter(Categoria.id == pieza.categoria_id).first():
            raise HTTPException(status_code=400, detail="Categoría no encontrada")

    if pieza.proveedor_id:
        if not db.query(Proveedor).filter(Proveedor.id == pieza.proveedor_id).first():
            raise HTTPException(status_code=400, detail="Proveedor no encontrado")

    db_pieza = Pieza(**pieza.dict())
    db.add(db_pieza)
    db.commit()
    db.refresh(db_pieza)
    return db_pieza


@router.put("/{pieza_id}", response_model=PiezaResponse)
def actualizar_pieza(
        pieza_id: int,
        pieza_update: PiezaUpdate,
        db: Session = Depends(get_db)
):
    """Actualizar una pieza existente"""
    pieza = db.query(Pieza).filter(Pieza.id == pieza_id).first()
    if not pieza:
        raise HTTPException(status_code=404, detail="Pieza no encontrada")

    # Actualizar solo los campos proporcionados
    update_data = pieza_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(pieza, field, value)

    db.commit()
    db.refresh(pieza)
    return pieza


@router.delete("/{pieza_id}")
def eliminar_pieza(pieza_id: int, db: Session = Depends(get_db)):
    """Eliminar una pieza"""
    pieza = db.query(Pieza).filter(Pieza.id == pieza_id).first()
    if not pieza:
        raise HTTPException(status_code=404, detail="Pieza no encontrada")

    db.delete(pieza)
    db.commit()
    return {"message": "Pieza eliminada exitosamente"}


@router.post("/{pieza_id}/imagenes")
async def subir_imagen(
        pieza_id: int,
        file: UploadFile = File(...),
        es_principal: bool = False,
        descripcion: Optional[str] = None,
        db: Session = Depends(get_db)
):
    """Subir una imagen para una pieza"""
    # Verificar que la pieza existe
    pieza = db.query(Pieza).filter(Pieza.id == pieza_id).first()
    if not pieza:
        raise HTTPException(status_code=404, detail="Pieza no encontrada")

    # Validar extensión del archivo
    file_extension = Path(file.filename).suffix.lower()
    if file_extension not in settings.ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Tipo de archivo no permitido. Extensiones permitidas: {settings.ALLOWED_EXTENSIONS}"
        )

    # Crear nombre único para el archivo
    unique_filename = f"{uuid.uuid4()}{file_extension}"
    file_path = settings.UPLOAD_FOLDER / unique_filename

    # Guardar el archivo
    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al guardar el archivo: {str(e)}")

    # Si es principal, desmarcar otras imágenes como principales
    if es_principal:
        db.query(ImagenPieza).filter(ImagenPieza.pieza_id == pieza_id).update(
            {"es_principal": False}
        )

    # Guardar registro en BD
    imagen = ImagenPieza(
        pieza_id=pieza_id,
        filename=file.filename,
        filepath=str(file_path),
        es_principal=es_principal,
        descripcion=descripcion
    )
    db.add(imagen)
    db.commit()
    db.refresh(imagen)

    return {
        "message": "Imagen subida exitosamente",
        "imagen_id": imagen.id,
        "filename": imagen.filename
    }