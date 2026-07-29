resource "helm_release" "argocd" {
  name             = "argocd"
  
  # OCI registry configuration
  repository       = "oci://ghcr.io/argoproj/argo-helm"
  chart            = "argo-cd"
  
  namespace        = "argocd"
  create_namespace = true

  depends_on = [
    minikube_cluster.minikube_docker
  ]

  values = [
    <<EOF
    server:
      service:
        type: ClusterIP
    EOF
  ]
}