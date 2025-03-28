
# Use official Python runtime with slim version 
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1 
ENV PYTHONUNBUFFERED 1
ENV FLASK_APP=main.py 
ENV FLASK_ENV=production

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8081


CMD ["flask", "run", "--host=0.0.0.0", "--port=8081"]