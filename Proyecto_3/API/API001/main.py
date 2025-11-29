# main.py - API PaquetExpress
from fastapi import FastAPI, HTTPException, Depends, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import create_engine, Column, Integer, String, TIMESTAMP, DECIMAL
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from pydantic import BaseModel
from datetime import datetime
import requests, shutil, os, hashlib

# ==========================================
# CONFIGURACIÓN DE BASE DE DATOS
# ==========================================
DATABASE_URL = "mysql+pymysql://root:@localhost:3307/paquexpress_db"

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

app = FastAPI(title="Paquexpress API")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Carpeta de fotos
os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# ==========================================
# MODELOS SQLALCHEMY
# ==========================================
class User(Base):
    __tablename__ = "p3_users"
    user_id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True)
    password_hash = Column(String(255))
    full_name = Column(String(100))
    role = Column(String(20), default="agent")
    created_at = Column(TIMESTAMP, default=datetime.utcnow)


class Package(Base):
    __tablename__ = "p3_packages"
    package_id = Column(Integer, primary_key=True)
    user_id = Column(Integer)
    client_name = Column(String(255))
    address = Column(String(255))
    latitude = Column(DECIMAL(10,8))
    longitude = Column(DECIMAL(11,8))
    delivered = Column(Integer, default=0)
    delivery_photo = Column(String(255))
    delivery_lat = Column(DECIMAL(10,8))
    delivery_lng = Column(DECIMAL(11,8))
    delivery_address = Column(String(255))
    delivered_at = Column(TIMESTAMP)


Base.metadata.create_all(bind=engine)

# ==========================================
# UTILS
# ==========================================
def md5_hash(text: str):
    return hashlib.md5(text.encode()).hexdigest()


def geocode_address(address: str):
    """Convierte dirección -> lat/lng"""
    url = f"https://nominatim.openstreetmap.org/search?q={address}&format=json&limit=1"
    headers = {"User-Agent": "PaquexpressApp"}
    try:
        r = requests.get(url, headers=headers, timeout=10)
        if r.status_code == 200:
            data = r.json()
            if data:
                return float(data[0]["lat"]), float(data[0]["lon"])
    except:
        return None, None
    return None, None


def reverse_geocode(lat, lng):
    """Convierte lat/lng -> dirección"""
    url = f"https://nominatim.openstreetmap.org/reverse?lat={lat}&lon={lng}&format=json"
    headers = {"User-Agent": "PaquexpressApp"}
    try:
        r = requests.get(url, headers=headers, timeout=10)
        if r.status_code == 200:
            return r.json().get("display_name", "Dirección no disponible")
    except:
        return "Dirección no disponible"
    return "Dirección no disponible"

# ==========================================
# SCHEMAS
# ==========================================
class LoginSchema(BaseModel):
    username: str
    password: str


class CreatePackageSchema(BaseModel):
    user_id: int
    client_name: str
    address: str


# ==========================================
# DEPENDENCIA DB
# ==========================================
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==========================================
# ENDPOINTS
# ==========================================
@app.post("/login/")
def login(data: LoginSchema, db=Depends(get_db)):
    user = db.query(User).filter(User.username == data.username).first()
    if not user or user.password_hash != md5_hash(data.password):
        raise HTTPException(status_code=400, detail="Credenciales inválidas")
    return {
        "msg": "Login exitoso",
        "user_id": user.user_id,
        "role": user.role,
        "full_name": user.full_name
    }


@app.post("/packages/create/")
def create_package(data: CreatePackageSchema, db=Depends(get_db)):
    lat, lng = geocode_address(data.address)

    pkg = Package(
        user_id=data.user_id,
        client_name=data.client_name,
        address=data.address,
        latitude=lat,
        longitude=lng
    )

    db.add(pkg)
    db.commit()
    db.refresh(pkg)

    return {
        "msg": "Paquete creado",
        "package_id": pkg.package_id,
        "latitude": lat,
        "longitude": lng
    }


@app.get("/packages/{user_id}")
def get_packages(user_id: int, db=Depends(get_db)):
    pkgs = db.query(Package).filter(
        Package.user_id == user_id,
        Package.delivered == 0
    ).all()

    return [
        {
            "package_id": p.package_id,
            "client_name": p.client_name,
            "address": p.address,
            "latitude": float(p.latitude) if p.latitude else None,
            "longitude": float(p.longitude) if p.longitude else None,
        } for p in pkgs
    ]


@app.post("/deliver/")
def deliver_package(
    package_id: int = Form(...),
    user_id: int = Form(...),
    latitude: float = Form(...),
    longitude: float = Form(...),
    photo: UploadFile = File(...),
    db=Depends(get_db)
):
    pkg = db.query(Package).filter(Package.package_id == package_id).first()
    if not pkg:
        raise HTTPException(status_code=404, detail="Paquete no encontrado")

    # Guardar foto
    filename = f"deliver_{package_id}_{int(datetime.utcnow().timestamp())}_{photo.filename}"
    save_path = os.path.join("uploads", filename)
    with open(save_path, "wb") as buffer:
        shutil.copyfileobj(photo.file, buffer)

    # Reverse geocode
    entrega_address = reverse_geocode(latitude, longitude)

    pkg.delivered = 1
    pkg.delivery_photo = save_path
    pkg.delivery_lat = latitude
    pkg.delivery_lng = longitude
    pkg.delivery_address = entrega_address
    pkg.delivered_at = datetime.utcnow()

    db.commit()

    return {
        "msg": "Paquete entregado",
        "delivery_address": entrega_address
    }
