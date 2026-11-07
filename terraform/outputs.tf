# ---- Cluster access ----
output "kube_context" {
  description = "kubectl context for the cluster"
  value       = "kind-${var.cluster_name}"
}

# ---- Argo CD access ----
output "argocd_ui" {
  description = "Open the Argo CD UI at https://localhost:8081 (user: admin)"
  value       = "kubectl -n argocd port-forward svc/argocd-server 8081:443"
}

output "argocd_admin_password" {
  description = "Print the initial admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}