## Instrucciones de instalación y uso

### 1) Configurar la Base de Datos (MySQL)
1. Abre tu gestor MySQL (phpMyAdmin, MySQL Workbench o consola).
2. Crea la base de datos:
   ```sql
   CREATE DATABASE paquexpress_db;
   
Importa el archivo SQL del modelo (bd_modelo/modelo_paquetes.sql) desde la interfaz de phpMyAdmin o con:
mysql -u root -p paquexpress_db < bd_modelo/modelo_paquetes.sql


### 2) Configurar y ejecutar la API (Python / FastAPI)
Abre una terminal y entra a la carpeta del backend:
cd api_python

Crea un entorno virtual (recomendado) e instala dependencias:
python -m venv venv
source venv/bin/activate   # Linux/Mac
venv\Scripts\activate      # Windows
pip install -r requirements.txt


Configura la cadena de conexión en el archivo de configuración (ej. main.py):
DATABASE_URL = "mysql+pymysql://root:TU_PASSWORD@localhost:3306/paquexpress_db"

Ejecuta la API:
uvicorn main:app --reload
La API quedará disponible en http://127.0.0.1:8000.

### 3) Ejecutar la aplicación Flutter (App móvil)
Abre la carpeta del proyecto Flutter:
cd app_flutter

Instala dependencias:
flutter pub get


Conecta un emulador o dispositivo y ejecuta:
flutter run
En la configuración de la app, asegúrate de apuntar las llamadas HTTP a la URL donde corre la API (http://IP_DEL_SERVIDOR:8000 si usas un dispositivo físico).

### 4) Flujo de uso básico
Iniciar sesión con un usuario válido (creado en la base de datos).

Descargar paquetes asignados: la app consume /packages/{user_id}.

Al entregar, tomar foto y enviar a POST /deliver/ con multipart/form-data incluyendo:

package_id, user_id, latitude, longitude y photo.

Verificar en la base de datos que el paquete cambió a delivered = 1 y que delivery_photo, delivery_lat, delivery_lng, delivery_address y delivered_at estén registrados.
