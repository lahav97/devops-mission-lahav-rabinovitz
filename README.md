# DevOps Exercise – Lahav Rabinovitz

Take a small web service from code to a running deployment on a local
Kubernetes cluster, the GitOps way.

## Tools

| Area | Tool | Why |
|---|---|---|
| Containers | Docker Desktop | Standard on macOS, required by kind |
| Local cluster | kind | Multi-node clusters in Docker, fast to create and destroy |
| Infrastructure as code | Terraform (kind + Helm providers) | One `apply` / `destroy` for the cluster and its add-ons |
| GitOps | Argo CD | Syncs the manifests in this repo to the cluster |
| Manifests | Kustomize | Plain YAML plus one field for the image tag that CI updates |
| Ingress | Traefik | Maintained controller with the standard Ingress API (ingress-nginx was retired in March 2026) |
| Service | Node.js + Express | Small, familiar, quick to containerize |
| CI/CD | GitHub Actions + GitHub Container Registry (GHCR) | Builds and pushes images, then updates the image tag in git |

## Plan

### Part 0 – Set up and plan
- [x] Install tools, log in to GitHub, create the repo
- [x] Write this plan
- [x] Express service: `GET /` returns HTML (message, version, pod name), `GET /healthz` returns 200
- [x] Small automated test for both endpoints
- [x] Dockerfile running as a non-root user; build and run locally

### Part 1 – Cluster as code
- [x] Terraform creates a kind cluster (1 control-plane + 2 workers)
- [x] Terraform installs Argo CD and Traefik with Helm
- [x] `terraform apply` brings everything up; `terraform destroy` removes it

### Part 2 – GitOps deployment
- [x] Manifests in `k8s/`: Deployment (2 replicas, probes, requests/limits), Service, Ingress
- [x] Argo CD Application pointing at `k8s/`
- [x] App opens in the browser through the Ingress

### Part 3 – CI/CD
- [ ] On push to `main`: test, build, push the image to GHCR tagged with the commit SHA
- [ ] Workflow commits the new image tag to `k8s/`; Argo CD rolls it out (no `kubectl apply` from CI)
- [ ] Zero-downtime check: a request loop shows no failures during a rollout

### Bonus (if time allows)
- [ ] Horizontal Pod Autoscaler (min 2, max 5)
- [ ] Prometheus and Grafana through Argo CD
- [ ] Notes on running this on EKS in production

## Repository layout

~~~
app/                 Node.js service, tests and Dockerfile
terraform/           kind cluster, Argo CD and Traefik
k8s/                 Kubernetes manifests (Kustomize) synced by Argo CD
argocd/              Argo CD Application (bootstrap, applied once)
.github/workflows/   CI/CD pipeline
ai-prompts.md        Prompts given to the AI assistant
~~~

## How to run

### App locally
~~~bash
cd app && npm install && npm test && npm start
~~~
Open http://localhost:8080

### App in Docker
~~~bash
docker build -t devops-exercise:local --build-arg APP_VERSION=local-test ./app
docker run --rm -p 8080:8080 devops-exercise:local
~~~

### Cluster (Terraform)
~~~bash
cd terraform
terraform init
terraform apply      # kind cluster + Traefik + Argo CD
terraform destroy    # removes everything
~~~
- Traffic path: Mac port 80 → kind control-plane node (`extraPortMappings`) → Traefik pod (`hostPort: 80`).
- Argo CD UI: `kubectl -n argocd port-forward svc/argocd-server 8081:443`, then https://localhost:8081 (user `admin`, password command from `terraform output argocd_admin_password`).

### Deploy the app (GitOps)
~~~bash
kind load docker-image devops-exercise:local --name devops   # until CI pushes to GHCR
kubectl apply -f argocd/application.yaml                     # one-time bootstrap
~~~
Open http://localhost. Argo CD syncs `k8s/` from `main` automatically (polls every 60s).

- The Ingress has no host rule, so it answers on any hostname. That's fine for a single app on a laptop; in production each app gets its own host.
- The Deployment uses rolling updates with `maxUnavailable: 0` and a 5-second `preStop` sleep, so the ingress stops routing to a pod before it shuts down.

## Summary

### What I finished
_TBD_

### What's missing
_TBD_

### One decision I made and why
_TBD_

### One place where the AI was wrong and how I noticed
_TBD_