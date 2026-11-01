# Imagen base ligera con Python 3.12
FROM python:3.12-slim

# Python sin ficheros .pyc y con logs sin buffer; PORT = puerto interno de la API
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8000

# Usuario sin privilegios para no ejecutar la app como root
RUN useradd --create-home --uid 1000 appuser

WORKDIR /app

# 1) Primero solo las dependencias: si no cambian, Docker reutiliza esta capa (cache)
COPY requirements.txt .
RUN pip install -r requirements.txt

# 2) Después el código fuente, con permisos para el usuario appuser
COPY --chown=appuser:appuser src/ .

USER appuser

EXPOSE 8000

# Arranque de la API; 0.0.0.0 permite recibir conexiones desde fuera del contenedor
CMD ["sh", "-c", "exec uvicorn main:app --host 0.0.0.0 --port ${PORT}"]
