FROM python:3.11-slim

WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y \
    wget curl jq ca-certificates tar gzip gcc libc-dev \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---- Dynamically fetch pinned Geth version ----
ENV GETH_VERSION=1.13.14

RUN LATEST_URL=$(curl -s https://api.github.com/repos/ethereum/go-ethereum/releases/tags/v${GETH_VERSION} \
    | jq -r '.assets[] | select(.name | test("linux-amd64.*tar.gz$")) | .browser_download_url') \
    && wget -q $LATEST_URL -O geth.tar.gz \
    && tar -xvzf geth.tar.gz \
    && mv geth-linux-amd64-${GETH_VERSION}-*/geth /usr/local/bin/geth \
    && rm -rf geth.tar.gz geth-linux-amd64-${GETH_VERSION}-*

# ---- Python dependencies ----
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# ---- App code ----
COPY . /app/

# Permissions
RUN chmod +x /app/entrypoint.sh

EXPOSE 8000 8545

# Health check for app
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:8000/status || exit 1

CMD ["/app/entrypoint.sh"]
