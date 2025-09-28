FROM python:3.11-slim

WORKDIR /app

# Install system deps (gcc for psutil, curl for healthcheck, geth for blockchain)
RUN apt-get update && apt-get install -y \
    gcc libc-dev curl software-properties-common \
    && add-apt-repository -y ppa:ethereum/ethereum \
    && apt-get update && apt-get install -y ethereum \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy app files
COPY . /app/

# Permissions
RUN chmod +x /app/entrypoint.sh

EXPOSE 8000 8545

# Health check using FastAPI endpoint
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:8000/status || exit 1

CMD ["/app/entrypoint.sh"]
