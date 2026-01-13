# Django-USSD Deployment Files

## 1. Dockerfile
Place at: `/home/user/openspace/django-ussd/Dockerfile`

```dockerfile
FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

FROM base AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

FROM base AS production

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY --chown=nobody:nogroup . .

RUN mkdir -p /app/logs && \
    touch /app/logs/ussd.log && \
    chown -R nobody:nogroup /app

USER nobody

EXPOSE 8097

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:8097/ || exit 1

CMD ["gunicorn", "project.wsgi:application", "--bind", "0.0.0.0:8097", "--workers", "2", "--timeout", "60"]
```

## 2. requirements.txt
Place at: `/home/user/openspace/django-ussd/requirements.txt`

```
Django==4.2.11
gunicorn==21.2.0
requests==2.31.0
```

## 3. docker-compose.yml (add this service)
Add to: `/home/user/openspace/docker-compose.yml`

```yaml
  django-ussd:
    build:
      context: ./django-ussd
      dockerfile: Dockerfile
    container_name: openspace_ussd
    restart: unless-stopped
    ports:
      - "8095:8097"
    environment:
      - BACKEND_URL=http://backend:8099
    depends_on:
      - backend
    networks:
      - openspace_network
```

## Configuration Summary

- **Internal Port:** 8097 (inside container)
- **External Port:** 8095 (on server)
- **Backend Communication:** http://backend:8099 (Docker network)
- **Africa's Talking Callback:** http://YOUR_PUBLIC_IP:8095/uploadussd/

## Deploy Commands

```bash
cd /home/user/openspace
docker-compose up -d django-ussd
docker-compose logs -f django-ussd
```
