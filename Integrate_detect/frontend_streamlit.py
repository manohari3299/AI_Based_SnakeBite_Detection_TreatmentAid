import streamlit as st
import requests
import os
from pathlib import Path

API = os.getenv("SNAKE_API_URL", "http://127.0.0.1:8000")
API_KEY = os.getenv("API_KEY", "changeme")


def headers():
    h = {}
    if API_KEY:
        h["X-API-KEY"] = API_KEY
    return h


st.title("Snake Detect Frontend")
st.write("A lightweight frontend that uses the FastAPI backend.")

uploaded = st.file_uploader("Upload snake image", type=["jpg", "png", "jpeg"])
if uploaded:
    files = {"file": (uploaded.name, uploaded, "image/jpeg")}
    with st.spinner("Uploading and predicting species..."):
        r = requests.post(f"{API}/predict_species", files=files, headers=headers())
    if r.status_code == 200:
        st.success("Prediction returned")
        st.json(r.json())
    else:
        st.error(f"Error: {r.status_code} - {r.text}")

st.markdown("---")
st.subheader("Chat with assistant")
species = st.text_input("Species (binomial name)")
msg = st.text_input("Your question")
if st.button("Send") and msg:
    payload = {"user_input": msg, "species_name": species, "chat_history": []}
    r = requests.post(f"{API}/chat", json=payload, headers=headers())
    if r.status_code == 200:
        st.json(r.json())
    else:
        st.error(f"Error: {r.status_code} - {r.text}")
