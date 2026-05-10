#!/bin/sh
# Reemplaza el placeholder BACKEND_URL en el HTML con la variable de entorno real
# Esto permite configurar la URL del backend sin reconstruir la imagen

BACKEND_URL=${BACKEND_URL:-http://localhost:3000}

sed -i "s|window.BACKEND_URL = window.BACKEND_URL || 'http://localhost:3000'|window.BACKEND_URL = '${BACKEND_URL}'|g" /usr/share/nginx/html/index.html

echo "✅ Frontend configurado con BACKEND_URL=${BACKEND_URL}"

# Iniciar Nginx
nginx -g "daemon off;"
