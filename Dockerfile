FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget tar gzip gcc libc-dev curl jq \
    && rm -rf /var/lib/apt/lists/*

# ---- Install pinned Geth version (reproducible) ----
ENV GETH_VERSION=1.13.14
ENV GETH_COMMIT=4f4aef9f
ENV GETH_URL=https://github.com/ethereum/go-ethereum/releases/download/v${GETH_VERSION}/geth-linux-amd64-${GETH_VERSION}-${GETH_COMMIT}.tar.gz

RUN wget ${GETH_URL} -O geth.tar.gz \
    && tar -xvzf geth.tar.gz \
    && mv geth-linux-amd64-${GETH_VERSION}-${GETH_COMMIT}/geth /usr/local/bin/geth \
    && rm -rf geth.tar.gz geth-linux-amd64-${GETH_VERSION}-${GETH_COMMIT}

# ---- Python dependencies ----
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# ---- App code ----
COPY . /app/

# Permissions
RUN chmod +x /app/entrypoint.sh

EXPOSE 8000 8545

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:8000/status || exit 1

CMD ["/app/entrypoint.sh"]
