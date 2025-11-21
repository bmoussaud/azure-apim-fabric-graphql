# Container image for orders-rest-api

FROM python:3.11-slim

# Prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set work directory inside the container
WORKDIR /app

# Install system dependencies (if needed for future growth) and create non-root user
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && useradd -m appuser \
    && rm -rf /var/lib/apt/lists/*

# Copy project metadata first for better caching
COPY pyproject.toml ./

# Install runtime dependencies directly from pyproject
RUN pip install --upgrade pip \
    && python - << 'EOF'
from tomllib import loads
from pathlib import Path

data = loads(Path('pyproject.toml').read_text())
deps = data.get('project', {}).get('dependencies', [])
if deps:
    import subprocess, sys
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', *deps])
EOF

# Copy the rest of the application code
COPY . .

# Switch to non-root user
USER appuser

# Expose the default FastAPI port
EXPOSE 8000

# Default command to run the API using uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
