# scripts/init_db.py
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.app.database import engine, Base, SessionLocal
from backend.app.models.pieza import Pieza
from backend.app.models.categoria import Categoria
from backend.app.models.proveedor import Proveedor
from backend.app.models.imagen import ImagenPieza


def init_database():
    """Inicializar la base de datos con datos de ejemplo"""

    # Crear todas las tablas
    Base.metadata.create_all(bind=engine)
    print("✅ Tablas creadas exitosamente")

    # Crear sesión
    db = SessionLocal()

    try:
        # Crear categorías de ejemplo
        categorias = [
            Categoria(codigo="ROD", nombre="Rodillos", descripcion="Rodillos para bandas transportadoras"),
            Categoria(codigo="BAN", nombre="Bandas", descripcion="Bandas transportadoras de diversos materiales"),
            Categoria(codigo="MOT", nombre="Motores", descripcion="Motores y motorreductores"),
            Categoria(codigo="POL", nombre="Poleas", descripcion="Poleas de transmisión"),
            Categoria(codigo="TEN", nombre="Tensores", descripcion="Sistemas de tensado"),
            Categoria(codigo="EST", nombre="Estructura", descripcion="Elementos estructurales"),
        ]

        for cat in categorias:
            existing = db.query(Categoria).filter(Categoria.codigo == cat.codigo).first()
            if not existing:
                db.add(cat)

        db.commit()
        print(f"✅ {len(categorias)} categorías creadas")

        # Crear proveedores de ejemplo
        proveedores = [
            Proveedor(
                codigo="PROV001",
                nombre="Industrial Supply Co.",
                telefono="+34 91 123 4567",
                email="contacto@industrialsupply.com",
                sitio_web="www.industrialsupply.com"
            ),
            Proveedor(
                codigo="PROV002",
                nombre="Bandas y Rodillos S.A.",
                telefono="+34 93 987 6543",
                email="ventas@bandasrodillos.es"
            ),
            Proveedor(
                codigo="PROV003",
                nombre="TechMotion Europe",
                telefono="+34 96 555 1234",
                email="info@techmotion.eu",
                sitio_web="www.techmotion.eu"
            ),
        ]

        for prov in proveedores:
            existing = db.query(Proveedor).filter(Proveedor.codigo == prov.codigo).first()
            if not existing:
                db.add(prov)

        db.commit()
        print(f"✅ {len(proveedores)} proveedores creados")

        # Crear algunas piezas de ejemplo
        piezas_ejemplo = [
            {
                "codigo": "ROD-001",
                "nombre": "Rodillo de retorno Ø89mm",
                "descripcion": "Rodillo de retorno con rodamientos sellados",
                "categoria_id": 1,
                "proveedor_id": 1,
                "especificaciones": {
                    "diametro": "89mm",
                    "longitud": "600mm",
                    "material": "Acero galvanizado",
                    "rodamiento": "6204-2RS"
                },
                "largo": 600,
                "ancho": 89,
                "peso": 3.5,
                "stock": 25,
                "stock_minimo": 10,
                "ubicacion_almacen": "A1-B3"
            },
            {
                "codigo": "BAN-001",
                "nombre": "Banda transportadora EP 400/3",
                "descripcion": "Banda de caucho con tejido EP, 3 telas",
                "categoria_id": 2,
                "proveedor_id": 2,
                "especificaciones": {
                    "tipo": "EP 400/3",
                    "ancho": "800mm",
                    "espesor": "10mm",
                    "resistencia": "400 N/mm",
                    "telas": "3",
                    "recubrimiento_superior": "4mm",
                    "recubrimiento_inferior": "2mm"
                },
                "ancho": 800,
                "peso": 12.5,
                "stock": 150,
                "stock_minimo": 50,
                "ubicacion_almacen": "B2-C1"
            },
            {
                "codigo": "MOT-001",
                "nombre": "Motorreductor 5.5kW",
                "descripcion": "Motorreductor de ejes paralelos",
                "categoria_id": 3,
                "proveedor_id": 3,
                "especificaciones": {
                    "potencia": "5.5kW",
                    "voltaje": "380V",
                    "frecuencia": "50Hz",
                    "rpm_salida": "45",
                    "reduccion": "1:30",
                    "eficiencia": "IE3"
                },
                "largo": 450,
                "ancho": 300,
                "alto": 350,
                "peso": 65,
                "stock": 5,
                "stock_minimo": 2,
                "ubicacion_almacen": "D1-A2"
            }
        ]

        for pieza_data in piezas_ejemplo:
            existing = db.query(Pieza).filter(Pieza.codigo == pieza_data["codigo"]).first()
            if not existing:
                pieza = Pieza(**pieza_data)
                db.add(pieza)

        db.commit()
        print(f"✅ {len(piezas_ejemplo)} piezas de ejemplo creadas")

        print("\n🎉 Base de datos inicializada correctamente!")
        print("\nResumen:")
        print(f"  - Categorías: {db.query(Categoria).count()}")
        print(f"  - Proveedores: {db.query(Proveedor).count()}")
        print(f"  - Piezas: {db.query(Pieza).count()}")

    except Exception as e:
        print(f"❌ Error al inicializar la base de datos: {str(e)}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    print("🚀 Iniciando configuración de base de datos...")
    init_database()