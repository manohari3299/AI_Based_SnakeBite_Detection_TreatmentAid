"""Helper chat utilities usable from both Streamlit and FastAPI backends.

This module provides simple, backend-agnostic helpers that operate on a
chat_history list (list of (sender, message) tuples). The original
project used Streamlit session state; for a FastAPI backend we manage
chat history in the client or persistence layer and pass it into these
functions.
"""

from typing import List, Tuple

ChatHistory = List[Tuple[str, str]]


def init_chat_history() -> ChatHistory:
    """Create an empty chat history list.

    Returns:
        An empty list that the API or caller can keep and pass back on
        subsequent requests.
    """
    return []


def append_chat(chat_history: ChatHistory, sender: str, msg: str) -> None:
    """Append a (sender, message) tuple to the provided chat_history list.

    This keeps the helper side-effect free for backends that store
    state externally.
    """
    chat_history.append((sender, msg))


def format_chat(chat_history: ChatHistory) -> str:
    """Return a text representation of the chat history suitable for
    passing to an LLM prompt.
    """
    return "\n".join([f"{s}: {m}" for s, m in chat_history])
