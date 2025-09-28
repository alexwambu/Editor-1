# ---- Base Python runtime ----
FROM python:3.11-slim

WORKDIR /app

# ---- Install system dependencies ----
RUN apt-get update && apt-get install -y \
    wget curl jq ca-certificates tar gzip gcc libc-dev \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---- Dynamically fetch pinned Geth version ----
ENV GETH_VERSION=1.13.14

RUN set -ex \
    && API_URL="https://api.github.com/repos/ethereum/go-ethereum/releases/tags/v${GETH_VERSION}" \
    && DOWNLOAD_URL=$(curl -sSL $API_URL | jq -r '.assets[] | select(.name | test("linux-amd64.*tar.gz$")) | .browser_download_url' | head -n1) \
    && echo "Downloading Geth from: $DOWNLOAD_URL" \
    && wget -q $DOWNLOAD_URL -O geth.tar.gz \
    && tar -xzf geth.tar.gz \
    && mv geth-linux-amd64-${GETH_VERSION}-*/geth /usr/local/bin/geth \
    && rm -rf geth.tar.gz geth-linux-amd64-${GETH_VERSION}-*

# ---- Python dependencies ----
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# ---- Copy app code ----
COPY . /app/

# ---- Permissions ----
RUN chmod +x /app/entrypoint.sh

# ---- Expose ports ----
EXPOSE 8000 8545

# ---- Health check ----
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8000/status || exit 1

# ---- Entrypoint ----
CMD ["/app/entrypoint.sh"]
