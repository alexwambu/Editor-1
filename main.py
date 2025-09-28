import psutil
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

import blockchain_launcher
from chatbot import generate_response
from ml_runner import run_ml_code

app = FastAPI()

# Serve frontend
app.mount("/", StaticFiles(directory="static", html=True), name="static")

# Middleware for frontend calls
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/status")
def healthcheck():
    """Check API + blockchain node health"""
    health = {
        "status": "ok",
        "service": "ML Editor + Chatbot + Blockchain",
        "blockchain_running": False
    }
    for proc in psutil.process_iter(attrs=["name"]):
        if "geth" in proc.info["name"].lower():
            health["blockchain_running"] = True
            break
    return health

@app.post("/launch_blockchain")
def launch_blockchain():
    blockchain_launcher.launch_node()
    return {"message": "Blockchain launch command sent"}

@app.post("/run_ml")
def run_ml(code: str):
    output = run_ml_code(code)
    return {"output": output}

@app.websocket("/chat")
async def websocket_chat(ws: WebSocket):
    await ws.accept()
    while True:
        msg = await ws.receive_text()
        response = generate_response(msg)
        await ws.send_text(response)
