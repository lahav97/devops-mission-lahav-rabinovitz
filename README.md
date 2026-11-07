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
| CI/CD | GitHub Actions + GitHub Container Registry (GHCR) | Tests, builds a multi-arch image, then updates the image tag in git |

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
- [x] `terraform apply` brings everything up; `terraform destroy` removes it (destroy not re-tested live – see "What's missing")

### Part 2 – GitOps deployment
- [x] Manifests in `k8s/`: Deployment (2 replicas, probes, requests/limits), Service, Ingress
- [x] Argo CD Application pointing at `k8s/`
- [x] App opens in the browser through the Ingress

### Part 3 – CI/CD
- [x] On push to `main`: test, build, push the image to GHCR tagged with the commit SHA
- [x] Workflow commits the new image tag to `k8s/`; Argo CD rolls it out (no `kubectl apply` from CI)
- [x] Zero-downtime check: a request loop shows no failures during a rollout

### Bonus (if time allows)
- [ ] Horizontal Pod Autoscaler (min 2, max 5)
- [ ] Prometheus and Grafana through Argo CD
- [x] Notes on running this on EKS in production (below)

## Repository layout

~~~
app/                 Node.js service, tests and Dockerfile
terraform/           kind cluster, Argo CD and Traefik
k8s/                 Kubernetes manifests (Kustomize) synced by Argo CD
argocd/              Argo CD Application (bootstrap, applied once)
scripts/             Zero-downtime load check
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
kubectl apply -f argocd/application.yaml   # one-time bootstrap
~~~
Open http://localhost. Argo CD syncs `k8s/` from `main` automatically (polls every 60s).

- The Ingress has no host rule, so it answers on any hostname. That's fine for a single app on a laptop; in production each app gets its own host.
- Rolling updates use `maxUnavailable: 0` and a 5-second `preStop` sleep, so the ingress stops routing to a pod before it shuts down.
- Before CI existed, the first deployment used a locally built image loaded with `kind load docker-image`. Since Part 3 the image comes from GHCR.

### CI/CD flow
1. Push to `main` → **checks** job: `npm test`, `terraform fmt -check`, `terraform validate`, `kubectl kustomize k8s`.
2. **build-and-deploy** job (main only, after checks pass): builds a multi-arch image (amd64 + arm64, because the kind nodes on Apple Silicon are arm64) and pushes `ghcr.io/lahav97/devops-mission-lahav-rabinovitz:<commit SHA>`.
3. The job updates `newTag` in `k8s/kustomization.yaml` with `yq` and commits it. Commits made with `GITHUB_TOKEN` don't trigger new runs, so there is no loop.
4. Argo CD sees the new commit and rolls out the new image. CI never runs `kubectl`.

> CI commits to `main`, so always `git pull` before making local changes.

### Zero-downtime check
~~~bash
./scripts/load-check.sh      # terminal 1: request loop, counts failures
# terminal 2: change MESSAGE in app/src/app.js, commit, push
~~~
Result during the v1 → v2 rollout: **`Total: 856  Failed: 0`**. That's 856 requests over about 3 minutes while both pods were replaced.

## Summary

### What I finished
Parts 0–3: the Express service with tests, a non-root Docker image, a Terraform-managed kind cluster (1 control-plane + 2 workers) with Traefik and Argo CD, GitOps deployment through Argo CD (2 replicas, probes, resources, Ingress), and a CI/CD pipeline that tests, builds a multi-arch image to GHCR and updates the tag in git for Argo CD to roll out, with a zero-downtime rollout verified by a request loop (856 requests, 0 failures).

### What's missing
- HPA, and Prometheus/Grafana (bonus items).
- `terraform destroy` followed by a fresh `apply` was not re-run end to end today, to keep the cluster running for the review.
- Argo CD shows the app as `Progressing` because the Ingress never gets a `status.loadBalancer` address (Traefik runs with `hostPort` and a ClusterIP Service). The app itself is fully served. A fix would be to configure Traefik to publish a fixed address to Ingress status.
- The Argo CD Application is bootstrapped with one manual `kubectl apply`. It could be created by Terraform with the `argo/argocd-apps` Helm chart.
- Argo CD polls git every 60s; a GitHub webhook would make syncs instant.
- Bump the GitHub Actions to versions that target Node 24 (CI shows deprecation warnings).
- The AI prompts for Parts 0–2 were committed in one batch instead of with each change (noted at the top of `ai-prompts.md`).

### One decision I made and why
**Traefik instead of ingress-nginx.** ingress-nginx is the usual default for kind, but the Kubernetes project retired it in March 2026 (no more releases or security fixes). Traefik is actively maintained, has an official Helm chart, and supports the standard `Ingress` resource the exercise asks for, so the app manifests stay portable.

### One place where the AI was wrong and how I noticed
The AI wrote the Traefik Helm values with `service.type: ClusterIP`. On `terraform apply`, Helm rejected it: `at '/service': additional properties 'type' not allowed`. Chart 42.x moved the setting to `service.spec.type`. I checked the real values with `helm show values traefik/traefik --version 42.3.1`, fixed it, and applied again.

Smaller ones:
- The AI's README snippet nested code fences, so my copy was cut off. I noticed it in the VS Code preview.
- Its `.gitignore` rule didn't match the kubeconfig file the kind provider wrote (`terraform/devops-config`). I noticed it as an untracked file in `git status`.
- It picked GitHub Actions versions that still target Node 20, which shows up as deprecation warnings in CI.

## Running this on EKS in production
- **Cluster:** EKS through Terraform (the `terraform-aws-modules/eks` module), managed node groups or Karpenter across 3 AZs, remote state in S3 with locking.
- **Ingress:** AWS Load Balancer Controller (ALB) with ACM certificates and a real hostname via Route 53 / ExternalDNS.
- **Images:** ECR (or GHCR) with vulnerability scanning; pull access through node IAM roles instead of a public package.
- **Security:** IAM roles for service accounts (IRSA / EKS Pod Identity), secrets from AWS Secrets Manager via External Secrets, Argo CD behind SSO, CI pushing to AWS via OIDC instead of long-lived keys.
- **Reliability:** HPA plus cluster autoscaling, PodDisruptionBudget, topology spread across AZs, Prometheus/Grafana and alerting.
- **Delivery:** separate staging and production environments with promotion between them, branch protection on `main`, and an Argo CD webhook instead of polling.