# Tienda online (devops-practica)

**Autora:** Laura Alonso Camino

## Descripción
Aplicación Python que simula una tienda online. Gestiona usuarios (clientes y administradores),
productos (genéricos, electrónicos y de ropa) y pedidos con control de stock.

Es el proyecto de la Práctica 2: la lógica de negocio (`TiendaService`) se expone mediante una
**API REST con FastAPI**, que se consume desde un **cliente Python** (`requests`) y desde un
**frontend web**. En las siguientes prácticas se contenerizará con Docker.

## Estructura
```
Tienda_online/      API (FastAPI): main.py, schemas.py, models/ y services/
cliente_python/     Cliente de la API con requests
frontend/           Frontend web (HTML + JavaScript)
requirements.txt    Dependencias de Python
```

## Cómo ejecutarlo
```
pip install -r requirements.txt
cd Tienda_online
uvicorn main:app --reload
```
Documentación interactiva de la API: http://localhost:8000/docs

Cliente Python (con la API arrancada): `python cliente_python/cliente.py`
Frontend: abrir `frontend/index.html` en el navegador.

## Flujo de trabajo con Git
- `main`: rama principal, siempre estable.
- `feature/<nombre>`: una rama corta por cada tarea; se integra en `main` mediante Pull Request.
