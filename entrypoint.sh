#!/bin/sh
set -e

echo ">>> Initializing blockchain with genesis.json..."
if [ ! -d /app/data/geth ]; then
    geth --datadir /app/data init /app/genesis.json
fi

echo ">>> Starting blockchain node..."
nohup geth \
  --datadir /app/data \
  --networkid 9999 \
  --http --http.addr 0.0.0.0 --http.port 8545 \
  --http.api eth,net,web3,personal,miner \
  --allow-insecure-unlock \
  > geth.log 2>&1 &

echo ">>> Starting FastAPI server..."
exec uvicorn main:app --host 0.0.0.0 --port 8000
