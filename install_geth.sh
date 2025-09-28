#!/bin/sh
set -e

echo ">>> Fetching latest Geth release metadata..."
LATEST=$(curl -s https://api.github.com/repos/ethereum/go-ethereum/releases/latest | jq -r .tag_name)

echo ">>> Latest version: $LATEST"

URL=$(curl -s https://api.github.com/repos/ethereum/go-ethereum/releases/latest \
  | jq -r '.assets[] | select(.name | test("geth-linux-amd64")) | .browser_download_url')

echo ">>> Downloading from: $URL"

wget -O geth.tar.gz "$URL"
tar -xvzf geth.tar.gz
FOLDER=$(tar -tf geth.tar.gz | head -n1 | cut -f1 -d"/")
mv "$FOLDER/geth" /usr/local/bin/geth
rm -rf geth.tar.gz "$FOLDER"

echo ">>> Installed Geth version:"
geth version
