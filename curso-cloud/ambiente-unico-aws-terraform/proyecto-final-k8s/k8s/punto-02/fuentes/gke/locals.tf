# brew install --cask google-cloud-sdk
# gcloud init
# gcloud auth application-default login  #cuenta defaut configurada
# gcloud container clusters get-credentials mygke-cluster --region us-east1
# kubectl create clusterrolebinding your-dev-user-cluster-admin-binding --clusterrole=cluster-admin --user=w.marchanaranda@gmail.com

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: https://${try(module.gke.endpoint, "")}
    certificate-authority-data: ${try(module.gke.ca_certificate, "")}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: gke
  name: gke
current-context: gke
kind: Config
preferences: {}
users:
- name: gke
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: /bin/gke-gcloud-auth-plugin 
      #/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/gke-gcloud-auth-plugin
      installHint: Install gke-gcloud-auth-plugin for use with kubectl by following
        https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke
      provideClusterInfo: true
    # auth-provider:
    #   config:
    #     cmd-args: config config-helper --format=json
    #     cmd-path: "/opt/homebrew/bin/gcloud" 
    #     expiry-key: '{.credential.token_expiry}'
    #     token-key: '{.credential.access_token}'
    #   name: gcp
KUBECONFIG
}

## NO OLVIDAR CAMBIAR EL CMD-PATH GCLOUD por la ruta de su computador