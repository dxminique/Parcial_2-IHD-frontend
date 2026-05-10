# ============================================================
# STAGE 1: Builder
# Prepara los archivos estáticos
# ============================================================
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar archivos del frontend
COPY index.html ./
COPY entrypoint.sh ./

# ============================================================
# STAGE 2: Runtime (Nginx mínimo)
# ============================================================
FROM nginx:alpine AS runtime

# Crear usuario no root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar archivos estáticos al directorio de Nginx
COPY --from=builder /app/index.html /usr/share/nginx/html/index.html
COPY --from=builder /app/entrypoint.sh /entrypoint.sh
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Dar permisos de ejecución al entrypoint
RUN chmod +x /entrypoint.sh && \
    chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid

USER appuser

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:80/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
