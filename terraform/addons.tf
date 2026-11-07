# ---- Ingress controller: Traefik ----
resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = "42.3.1"
  namespace        = "traefik"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [yamlencode({
    # Run on the control-plane node, where port 80 is mapped to the Mac
    nodeSelector = {
      "node-role.kubernetes.io/control-plane" = ""
    }
    tolerations = [{
      key      = "node-role.kubernetes.io/control-plane"
      operator = "Exists"
      effect   = "NoSchedule"
    }]

    # Bind the HTTP entrypoint to port 80 on the node
    ports = {
      web = {
        hostPort = 80
      }
    }

    # No cloud load balancer in kind; hostPort handles external traffic
    # (chart 42.x moved the Service type under service.spec)
    service = {
      spec = {
        type = "ClusterIP"
      }
    }

    ingressClass = {
      enabled        = true
      isDefaultClass = true
    }
  })]
}

# ---- GitOps: Argo CD ----
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "10.14.0"
  namespace        = "argocd"
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [yamlencode({
    configs = {
      cm = {
        # Poll git every 60s instead of the default 180s (faster demo rollouts)
        "timeout.reconciliation" = "60s"
      }
    }
  })]
}