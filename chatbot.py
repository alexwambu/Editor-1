def generate_response(message: str) -> str:
    """Simple rule-based chatbot"""
    message = message.lower()
    if "hello" in message:
        return "Hi! I’m your blockchain + ML assistant 🤖"
    elif "blockchain" in message:
        return "The blockchain node is live and can be managed here."
    elif "ml" in message or "machine learning" in message:
        return "You can run ML code directly using the editor."
    else:
        return "I didn’t quite get that. Try asking about blockchain or ML."
