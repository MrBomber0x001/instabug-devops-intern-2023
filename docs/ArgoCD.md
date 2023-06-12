## ArgoCD Documentation

kubectl create ns argocd
kubectl apply -n argocd -f <https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml>

.\argocd-windows-amd64.exe admin initial-password -n argocd
    B8NzmJTQjm7-nRHU

```sh
 .\argocd-windows-amd64.exe cluster add minikube
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `minikube` with full cluster level privileges. Do you want to continue [y/N]? y
time="2023-06-12T04:07:50+03:00" level=info msg="ServiceAccount \"argocd-manager\" created in namespace \"kube-system\""
time="2023-06-12T04:07:50+03:00" level=info msg="ClusterRole \"argocd-manager-role\" created"
time="2023-06-12T04:07:50+03:00" level=info msg="ClusterRoleBinding \"argocd-manager-role-binding\" created"
time="2023-06-12T04:07:55+03:00" level=info msg="Created bearer token secret for ServiceAccount \"argocd-manager\""
Cluster 'https://172.18.227.155:8443' added
```