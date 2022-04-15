#!/bin/bash

USER_ID="syoh@ucsb.edu"
PROJECT_ID="testing-sandbox-324502"
REGION_CODE="us-central1-a"
HELM_CHART_VERSION="0.0.2-n009.hcb36596"

set -e

echo "DIY Cloud Computing for Data Science using R"
echo "--------------------------------------------"

echo "\n\n## Step 1: logging in as user, ${USER_ID}"
gcloud auth login "${USER_ID}" --no-browser --update-adc

echo "\n\n## Step 2: creating cluster under project, ${PROJECT_ID} in region, ${REGION_CODE}"
terraform -chdir=cluster init
terraform -chdir=cluster apply -var="project_id=${PROJECT_ID}" -var="region=${REGION_CODE}" -auto-approve

CLUSTER_NAME=$(terraform -chdir=cluster output -raw kubernetes_cluster_name)
gcloud container clusters get-credentials ${CLUSTER_NAME} --zone=${REGION_CODE} --project=${PROJECT_ID}

echo "\n\n## Step 3: deploying Rstudio application with Helm chart version, ${HELM_CHART_VERSION}"
helm repo add r-future https://diy-ds-cloud.github.io/r-future
helm repo update
helm install myrelease r-future/diy-r-future --version "${HELM_CHART_VERSION}" --wait

SERVICE_IP=$(kubectl get svc myrelease-diy-r-future-notebook --namespace default --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo "\n\n## Rstudio is available at URL: http://$SERVICE_IP:80"
