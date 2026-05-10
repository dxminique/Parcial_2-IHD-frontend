# 🌐 Frontend Innovatech Chile — EP2 ISY1101

Aplicación frontend de Innovatech Chile, construida con **HTML + JavaScript + Nginx**, contenedorizada con Docker y desplegada automáticamente en AWS EC2 mediante GitHub Actions.

---

## 📐 Arquitectura

```
Internet
   │
   ▼
[EC2 Frontend - subred pública 10.0.1.0/24]
   │  contenedor: innovatech-frontend (Nginx :80)
   │  variable: BACKEND_URL=http://10.0.2.10:3000
   │
   │  HTTP → IP privada EC2 Backend
   ▼
[EC2 Backend - subred privada 10.0.2.0/24]
```

---

## 📦 Estructura del repositorio

```
innovatech-frontend/
├── index.html                     # Aplicación web (HTML + JS)
├── nginx.conf                     # Configuración del servidor Nginx
├── entrypoint.sh                  # Script que inyecta BACKEND_URL al iniciar
├── Dockerfile                     # Multi-stage build (builder + nginx runtime)
├── docker-compose.yml             # Stack del frontend
├── .env.example                   # Variables de entorno de referencia
├── .gitignore
└── .github/
    └── workflows/
        └── deploy.yml             # Pipeline CI/CD (build → push ECR → deploy EC2)
```

---

## 🐳 Dockerfile — Multi-stage Build

| Stage | Base | Propósito |
|-------|------|-----------|
| `builder` | `node:18-alpine` | Prepara archivos estáticos |
| `runtime` | `nginx:alpine` | Servidor web mínimo, usuario no root |

**Buenas prácticas aplicadas:**
- ✅ Multi-stage build
- ✅ Usuario no root (`appuser`)
- ✅ Imagen base mínima (`nginx:alpine`)
- ✅ `HEALTHCHECK` integrado
- ✅ `ENTRYPOINT` para inyección de variables de entorno

---

## ⚙️ Variables de entorno

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `BACKEND_URL` | URL del backend en EC2 privada | `http://10.0.2.10:3000` |

---

## 🚀 Cómo ejecutar localmente

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/innovatech-frontend.git
cd innovatech-frontend

# 2. Configurar variables de entorno
cp .env.example .env

# 3. Levantar el contenedor
docker compose up -d

# 4. Abrir en el navegador
http://localhost:80
```

---

## 🔗 Funcionalidades

- ✅ Visualización de estado del backend (health check)
- ✅ Listado de usuarios registrados
- ✅ Formulario para crear nuevos usuarios
- ✅ Actualización automática cada 10 segundos

---

## 🔄 Pipeline CI/CD

Se activa automáticamente al hacer **push a la rama `deploy`**:

```
push → rama deploy
        │
        ▼
   [Job 1: Build & Push]
   ├── Checkout código
   ├── Configurar credenciales AWS
   ├── Login a ECR
   ├── docker build (multi-stage)
   └── docker push → ECR (:sha + :latest)
        │
        ▼
   [Job 2: Deploy EC2]
   ├── SSH a EC2 Frontend
   ├── Pull nueva imagen desde ECR
   ├── docker stop + docker rm
   ├── docker run con BACKEND_URL
   └── curl /health (verificación)
```

### GitHub Secrets requeridos

| Secret | Descripción |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | Credencial AWS Academy |
| `AWS_SECRET_ACCESS_KEY` | Credencial AWS Academy |
| `AWS_SESSION_TOKEN` | Token de sesión AWS Academy |
| `EC2_FRONTEND_SSH_KEY` | Clave privada PEM de EC2 Frontend |
| `EC2_FRONTEND_HOST` | IP pública de EC2 Frontend |
| `BACKEND_URL` | URL del backend `http://10.0.2.10:3000` |

---

## 🛡️ Seguridad

- Solo el Frontend es accesible desde Internet (subred pública)
- El Backend está en subred privada, solo accesible desde el Frontend
- Credenciales gestionadas mediante GitHub Secrets

---

*EP2 — ISY1101 Introducción a Herramientas DevOps — DuocUC 2025*
