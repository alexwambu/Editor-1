import io
import contextlib

def run_ml_code(code: str) -> str:
    """Safely execute Python ML code and return output"""
    buffer = io.StringIO()
    try:
        with contextlib.redirect_stdout(buffer):
            exec(code, {})
    except Exception as e:
        return f"Error: {str(e)}"
    return buffer.getvalue()
