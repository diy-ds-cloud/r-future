[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/diy-ds-cloud/r-future/main?urlpath=git-pull%3Frepo%3Dhttps%253A%252F%252Fgithub.com%252Fdiy-ds-cloud%252Fr-future%26urlpath%3Dlab%252Ftree%252Fr-future%252F%26branch%3Dmain)


```bash
# gcloud init --no-browser
gcloud auth login syoh@ucsb.edu --no-browser --update-adc

PROJECT_ID="testing-sandbox-324502"
REGION_CODE="us-central1-a"

# gcloud config set core/project ${PROJECT_ID}
# gcloud config set compute/zone ${REGION_CODE}

# export PROJECT_ID=$(gcloud config get core/project)
# export REGION_CODE=$(gcloud config get compute/zone)

# echo "Default Project: $(gcloud config get core/project)"
# echo "Default Region: $(gcloud config get compute/zone)"

echo "Default Project: ${PROJECT_ID}"
echo "Default Region: ${REGION_CODE}"

# gcloud auth application-default login

terraform -chdir=work/cluster init
terraform -chdir=work/cluster apply -var="project_id=${PROJECT_ID}" -var="region=${REGION_CODE}" -auto-approve
# terraform -chdir=work/cluster destroy -var="project_id=${PROJECT_ID}" -var="region=${REGION_CODE}" -auto-approve

CLUSTER_NAME=$(terraform -chdir=work/cluster output -raw kubernetes_cluster_name)
gcloud container clusters get-credentials ${CLUSTER_NAME}

helm repo add r-future https://diy-ds-cloud.github.io/r-future
helm repo update
helm install myrelease r-future/diy-r-future --version 0.0.2-n009.hcb36596 --wait

SERVICE_IP=$(kubectl get svc myrelease-diy-r-future-notebook --namespace default --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo "Rstudio URL: http://$SERVICE_IP:80"

```
https://cloud.google.com/docs/terraform

export PROJECT=$(gcloud config get project)
export REGION=$(gcloud config get-value compute/zone)