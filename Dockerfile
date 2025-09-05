FROM python:3.11-slim

WORKDIR /app

COPY hello.py /app/hello.py

RUN chmod +x /app/hello.py

CMD ["python", "/app/hello.py"]
