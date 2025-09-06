# DevOps Intern Final Project

**Name:** Shikhar Shukla  
**Date:** 6th Sept 2025  

---

## Project Goal
The goal of this project is to build and document a DevOps workflow using open-source tools including **Linux, GitHub, Docker, CI/CD, Nomad, and monitoring tools**. Each step produces real, usable output for the next, simulating a small but realistic DevOps pipeline.

---

## Project Steps

### 1. Git & GitHub Setup
- Created a public repository: `devops-intern-final`.
- Added a `README.md` with name, date, and project description.
- Added a sample scripts: `hello.py` and `hello.sh` that prints `"Hello, DevOps!"`.
- **Output:** GitHub repository initialized with README and sample script.

```python
# hello.py
print("Hello, DevOps!")
```

```shell
# hello.py
print("Hello, DevOps!")
```

### 2. Linux & Scripting Basics

- Created a folder `scripts/` in the repo.
- Added a shell script `sysinfo.sh` to display:
  - Current user (`whoami`)
  - Current date (`date`)
  - Disk usage (`df -h`)
- Made the script executable (`chmod +x sysinfo.sh`).

**Output:** `scripts/sysinfo.sh` tested and working.

```bash
!/bin/bash
echo "------START------"
echo "User: $(whoami)"
echo "Date: $(date)"
echo "Disk usage (in human readable format):"
df -h
echo "------END------"
```

### 3. Docker Basics

- Created a `Dockerfile` to containerize `hello.py`.
- Container runs `python hello.py` on startup.
- Built and ran the container locally:

```bash
docker build -t devops-intern-hello:latest .
docker run -d --name my-sample-app1 devops-intern-hello:latest
docker logs 1702db8d0f66dd72b980
```

### 4. CI/CD with GitHub Actions

- Created a workflow: `.github/workflows/ci.yml`.
- Automatically runs `python hello.py` on every push.
- Added a **status badge** to this README.

**Workflow file:**

```yaml
# .github/workflows/ci.yml

name: CI
on:
  push:
  pull_request:

jobs:
  build:
    name: Run hello.py
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setting up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Upgrade pip
        run: python -m pip install --upgrade pip

      - name: Run hello.py
        run: python hello.py
```

### 5. Job Deployment with Nomad

- Created a Nomad job file: `nomad/hello.nomad`.
- Runs the Docker container as a `service`.
- Allocated minimal CPU & memory resources.

**Run the job:**

```bash
nomad job run hello.nomad
```

**Nomad file:**

```nomad
job "hello" {
  datacenters = ["dc1"]
  type        = "service"

  group "hello-group" {
    task "hello-task" {
      driver = "docker"

      config {
        image = "shikhrshukla/devops-intern-hello:latest"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
```

**Updated Python file:**
I have updated the python file because the deployment was becoming failed everytime as the container starts it stops suddenly, so I used ```sleep()``` funtion to maintain the deployment for 60 seconds.
```python
import time
print("Hello DevOps!")
while True:
  time.sleep(60)
```

### 6. Monitoring with Grafana Loki

**My Goal:**
I want to collect all the logs from my different Docker containers in one place. To do this, I used two programs: Loki and Promtail. Loki is like the main database where all the logs are stored. I can access it on port 3100. Promtail is a small helper program, its only job is to watch my log files and send everything it finds to Loki.

**Setup:**
I set it up using docker-compose for both programs and wrote a compose file (docker-compose.yml) that I already pushed to the hub. Then I configured Promtail with a small config file (promtail-config.yml). In this file, I told it two things: where my Loki server is and which log files to watch. I set the path to ```/var/lib/docker/containers/*/*-json.log``` to make sure it grabs logs from every container I run.

**Step to Run:**
I just run the command ```docker-compose up -d```, Once everything is up, I can pull logs directly from Loki using a curl command: ```curl "http://localhost:3100/loki/api/v1/query_range?query=%7Bjob%3D%22docker%22%7D&limit=5"``` Earlier, a simpler query was throwing an error, so I got help from ChatGPT to get the accurate query.

**The Simple Workflow:**
Promtail watches for new logs. It then sends them to Loki. Loki stores them, and I can search or query them anytime I want.


**Docker Compose File:**

```yaml
version: "3.8"

services:
  loki:
    image: grafana/loki:2.9.2
    container_name: loki
    ports:
      - "3100:3100"
    command: -config.file=/etc/loki/local-config.yaml

  promtail:
    image: grafana/promtail:2.9.2
    container_name: promtail
    volumes:
      - /var/log:/var/log
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./promtail-config.yml:/etc/promtail/config.yml
    command: -config.file=/etc/promtail/config.yml
```

**Promtail config:**

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

clients:
  - url: http://loki:3100/loki/api/v1/push

positions:
  filename: /tmp/positions.yaml

scrape_configs:
  - job_name: docker
    static_configs:
      - targets:
          - localhost
        labels:
          job: docker
          __path__: /var/lib/docker/containers/*/*-json.log
```
