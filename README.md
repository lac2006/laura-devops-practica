# Tienda online

**Autora:** Laura Alonso Camino

## Descripción
Aplicación Python que simula una tienda online. Gestiona usuarios (clientes y administradores),
productos (genéricos, electrónicos y de ropa) y pedidos con control de stock.
Expone su lógica (`TiendaService`) mediante una **API REST con FastAPI**, que se puede ejecutar
en local o dentro de un **contenedor Docker**.

## Estructura del repositorio
```
src/                API (FastAPI): main.py, schemas.py, models/ y services/ (TiendaService)
cliente_python/     Cliente de la API con requests
frontend/           Frontend web (HTML + JavaScript)
requirements.txt    Dependencias con versiones fijadas
Dockerfile          Definición de la imagen
.dockerignore       Archivos que no se copian a la imagen
```

## Ejecución en local (sin Docker)
```bash
pip install -r requirements.txt
cd src
uvicorn main:app --reload
```
Documentación interactiva: http://localhost:8000/docs

## Docker

Requisito: tener [Docker](https://docs.docker.com/get-docker/) instalado y en marcha.
Todos los comandos se ejecutan desde la **raíz del repositorio**.

### 1. Construir la imagen
```bash
docker build -t tienda-online:1.0.0 .
```
- `-t tienda-online:1.0.0` pone nombre y etiqueta (versión) a la imagen.
- Se parte de `python:3.12-slim`, se instalan las dependencias de `requirements.txt` y se copia `src/`.
- La app se ejecuta con un usuario sin privilegios (`appuser`), no como root.

Comprobar que existe y su tamaño:
```bash
docker images tienda-online
```

### 2. Ejecutar el contenedor
Ejemplo básico (la API queda en http://localhost:8000):
```bash
docker run --rm -p 8000:8000 tienda-online:1.0.0
```

En segundo plano y con nombre:
```bash
docker run -d --name tienda -p 8000:8000 tienda-online:1.0.0
docker logs tienda        # ver la salida
docker stop tienda        # parar
docker rm tienda          # borrar el contenedor
```

Usando otro puerto del ordenador (aquí el 9000):
```bash
docker run --rm -p 9000:8000 tienda-online:1.0.0
```

Cambiando el puerto interno con una variable de entorno:
```bash
docker run --rm -e PORT=8080 -p 8080:8080 tienda-online:1.0.0
```

### 3. Variables de entorno
| Variable | Valor por defecto | Descripción |
|---|---|---|
| `PORT` | `8000` | Puerto en el que escucha la API dentro del contenedor |

No hay secretos ni claves en la imagen. Si se necesitaran, se pasarían con `-e` o `--env-file`, nunca dentro del código.
Además, el cliente Python (`cliente_python/cliente.py`) lee la variable `API_URL` para saber a qué API conectarse.

### 4. Salida esperada y pruebas
Al arrancar, el contenedor debe mostrar algo parecido a:
```
INFO:     Started server process [1]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

Pruebas con el contenedor en marcha:

1. **Documentación:** abrir http://localhost:8000/docs
2. **Lista de productos** (debe devolver `[]` al empezar):
   ```bash
   curl http://localhost:8000/productos
   ```
3. **Crear un producto** (debe devolver código `201` y el producto con su `id`):
   ```bash
   curl -X POST http://localhost:8000/productos \
     -H "Content-Type: application/json" \
     -d '{"tipo":"generico","nombre":"Taza","precio":5.5,"stock":100}'
   ```
4. **Crear un usuario:**
   ```bash
   curl -X POST http://localhost:8000/usuarios \
     -H "Content-Type: application/json" \
     -d '{"nombre":"Ana","email":"ana@gmail.com","tipo":"cliente","direccion":"Calle Mayor 1"}'
   ```
5. **Flujo completo con el cliente Python** (debe terminar con los casos de error 404, 409 y 422):
   ```bash
   pip install -r requirements.txt
   python cliente_python/cliente.py http://localhost:8000
   ```
6. **Frontend:** abrir `frontend/index.html` en el navegador y usar `http://localhost:8000` como servidor.

> Los datos se guardan en memoria: al parar o reiniciar el contenedor se pierden.

### 5. Publicar y descargar la imagen (Docker Hub)
```bash
docker login
docker tag tienda-online:1.0.0 lac2006/tienda-online:1.0.0
docker tag tienda-online:1.0.0 lac2006/tienda-online:latest
docker push lac2006/tienda-online:1.0.0
docker push lac2006/tienda-online:latest
```

Para usar la imagen publicada desde cualquier equipo:
```bash
docker pull lac2006/tienda-online:1.0.0
docker run --rm -p 8000:8000 lac2006/tienda-online:1.0.0
```

## Flujo de trabajo con Git
- `main`: rama principal, siempre estable.
- `feature/<nombre>`: una rama corta por tarea; se integra en `main` mediante Pull Request.
