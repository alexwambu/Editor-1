import subprocess

def launch_node():
    """Launch a new geth node in background"""
    try:
        subprocess.Popen([
            "geth",
            "--datadir", "/app/data",
            "--networkid", "9999",
            "--http", "--http.addr", "0.0.0.0", "--http.port", "8545",
            "--http.api", "eth,net,web3,personal,miner",
            "--allow-insecure-unlock"
        ])
    except Exception as e:
        print("Error launching node:", e)
