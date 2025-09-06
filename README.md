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

### 2. Linux & Scripting Basics

- Created a folder `scripts/` in the repo.
- Added a shell script `sysinfo.sh` to display:
  - Current user (`whoami`)
  - Current date (`date`)
  - Disk usage (`df -h`)
- Made the script executable (`chmod +x sysinfo.sh`).

**Output:** `scripts/sysinfo.sh` tested and working.

```bash
#!/bin/bash
echo "Current user: $(whoami)"
echo "Current date: $(date)"
echo "Disk usage:"
df -h
```

### 3. Docker Basics

- Created a `Dockerfile` to containerize `hello.py`.
- Container runs `python hello.py` on startup.
- Built and ran the container locally:

```bash
docker build -t hello-devops .
docker run --rm hello-devops
```

### 4. CI/CD with GitHub Actions

- Created a workflow: `.github/workflows/ci.yml`.
- Automatically runs `python hello.py` on every push.
- Added a **status badge** to this README.

**Workflow file:**

```yaml
# .github/workflows/ci.yml
name: CI
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: 3.11
      - name: Run hello.py
        run: python hello.py
```

### 5. Job Deployment with Nomad

- Created a Nomad job file: `nomad/hello.nomad`.
- Runs the Docker container as a `service`.
- Allocated minimal CPU & memory resources.

**Run the job:**

```bash
nomad job run nomad/hello.nomad
```

**Nomad file:**

```yaml
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

### 6. Monitoring with Grafana Loki

- Configured Loki using a local Docker container.
- Set up **Promtail** to forward logs from Docker/Nomad containers to Loki.

**Logs viewing command:**

```bash
curl "http://localhost:3100/loki/api/v1/query_range?query=%7Bjob%3D%22docker%22%7D&limit=5"
```
