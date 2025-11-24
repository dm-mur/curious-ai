# Base image
FROM python:3.12-slim

# Working directory
WORKDIR /app

# Copy files
COPY . .

# Install dependencies
RUN pip install -r requirements.txt

# Install supervisord
RUN apt-get update && apt-get install -y supervisor

# Create supervisor config
RUN echo "[supervisord]\nnodaemon=true\n\n" \
    "[program:backend]\ncommand=uvicorn backend.server:app --host 0.0.0.0 --port 8000\n\n" \
    "[program:frontend]\ncommand=streamlit run frontend/app.py --server.port=8501 --server.address=0.0.0.0\n" \
    > /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 8501
EXPOSE 8000

# Start both services
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]