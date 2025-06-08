# Build stage
FROM python:3.9-alpine as builder

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    cairo \
    cairo-dev \
    cargo \
    freetype-dev \
    gcc \
    gdk-pixbuf-dev \
    gettext \
    jpeg-dev \
    lcms2-dev \
    libffi-dev \
    musl-dev \
    openjpeg-dev \
    openssl-dev \
    pango-dev \
    poppler-utils \
    postgresql-client \
    postgresql-dev \
    py-cffi \
    python3-dev \
    rust \
    tcl-dev \
    tiff-dev \
    tk-dev \
    zlib-dev \
    linux-headers

# Create and activate virtualenv
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Final stage
FROM python:3.9-alpine as final

WORKDIR /api

# Install runtime dependencies
RUN apk add --no-cache \
    postgresql-client \
    jpeg-dev \
    cairo \
    pango \
    gdk-pixbuf

# Copy virtualenv from builder
COPY --from=builder /opt/venv /opt/venv

# Set all environment variables before any Django commands
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH"

# Copy application code
COPY ./app /api

# Create static directory and set up permissions
RUN adduser --disabled-password --no-create-home api && \
    mkdir -p /vol/web/static && \
    mkdir -p /vol/web/media && \
    chown -R api:api /vol && \
    chown -R api:api /api && \
    chmod -R 755 /vol && \
    chmod -R 777 /vol/web

ENV PATH="/scripts:/opt/venv/bin:$PATH"

USER api

EXPOSE 8000
ENV PORT=8000

CMD python manage.py runserver 0.0.0.0:$PORT

