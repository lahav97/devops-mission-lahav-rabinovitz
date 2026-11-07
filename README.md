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
| Ingress | Ingress controller (chosen in Part 1) | Exposes the app to the browser on this laptop |
| Service | Node.js + Express | Small, familiar, quick to containerize |
| CI/CD | GitHub Actions + GitHub Container Registry (GHCR) | Builds and pushes images, then updates the image tag in git |

## Plan

### Part 0 – Set up and plan
- [x] Install tools, log in to GitHub, create the repo
- [x] Write this plan
- [ ] Express service: `GET /` returns HTML (message, version, pod name), `GET /healthz` returns 200
- [ ] Small automated test for both endpoints
- [ ] Dockerfile running as a non-root user; build and run locally

### Part 1 – Cluster as code
- [ ] Terraform creates a kind cluster (1 control-plane + 2 workers)
- [ ] Terraform installs Argo CD and an ingress controller with Helm
- [ ] `terraform apply` brings everything up; `terraform destroy` removes it

### Part 2 – GitOps deployment
- [ ] Manifests in `k8s/`: Deployment (2 replicas, probes, requests/limits), Service, Ingress
- [ ] Argo CD Application pointing at `k8s/`
- [ ] App opens in the browser through the Ingress

### Part 3 – CI/CD
- [ ] On push to `main`: test, build, push the image to GHCR tagged with the commit SHA
- [ ] Workflow commits the new image tag to `k8s/`; Argo CD rolls it out (no `kubectl apply` from CI)
- [ ] Zero-downtime check: a request loop shows no failures during a rollout

### Bonus (if time allows)
- [ ] Horizontal Pod Autoscaler (min 2, max 5)
- [ ] Prometheus and Grafana through Argo CD
- [ ] Notes on running this on EKS in production

## Repository layout