FROM python:3.11-slim

WORKDIR /app

# Copy project
COPY . /app

# Install build tools for some packages
RUN apt-get update && apt-get install -y build-essential git && rm -rf /var/lib/apt/lists/*

# Install Python deps. Note: for GPU/Windows-specific wheels, build locally and mount.
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
