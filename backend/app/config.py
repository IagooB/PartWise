from pydantic_settings import BaseSettings
from pathlib import Path


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str = "postgresql://usuario:password@localhost/banda_transportadora_db"

    # App
    APP_NAME: str = "Sistema de Gestión de Piezas"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = True

    # File Upload
    UPLOAD_FOLDER: Path = Path("uploads")
    MAX_FILE_SIZE: int = 5 * 1024 * 1024  # 5MB
    ALLOWED_EXTENSIONS: set = {".jpg", ".jpeg", ".png", ".pdf"}

    # Security (para futuro)
    SECRET_KEY: str = "tu-secret-key-super-segura-cambiar-en-produccion"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    class Config:
        env_file = ".env"


settings = Settings()

# Crear carpeta de uploads si no existe
settings.UPLOAD_FOLDER.mkdir(exist_ok=True)