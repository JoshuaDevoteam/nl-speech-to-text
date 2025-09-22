# Multi-stage build for efficient Python backend with UV package manager

# Stage 1: Build stage with UV
FROM python:3.11-slim as builder

# Copy UV from the official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set UV environment variables
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Install dependencies with UV
RUN uv sync --frozen --no-dev

# Stage 2: Runtime stage
FROM python:3.11-slim

# Install system dependencies for audio processing and Google Cloud
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libprotobuf-dev \
    protobuf-compiler \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8000 \
    PATH="/app/.venv/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /app/.venv ./.venv

# Copy application code
COPY --from=builder /app .

# Create non-root user
RUN useradd -m -u 1001 appuser && chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/ || exit 1

# Expose port
EXPOSE ${PORT}

# Run the application
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]