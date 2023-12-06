gcloud auth list

gcloud config list project

Task 1

export PROJECT_ID=$(gcloud config get-value project)
export REGION=us-central1
gcloud config set compute/region $REGION



Task 2

gcloud services enable \
container.googleapis.com \
clouddeploy.googleapis.com


gcloud container clusters create test --node-locations=us-central1-f --num-nodes=1  --async
gcloud container clusters create staging --node-locations=us-central1-f --num-nodes=1  --async
gcloud container clusters create prod --node-locations=us-central1-f --num-nodes=1  --async


gcloud container clusters list --format="csv(name,status)"




Task 3



gcloud services enable artifactregistry.googleapis.com

gcloud artifacts repositories create web-app \
--description="Image registry for tutorial web app" \
--repository-format=docker \
--location=$REGION





Task 4

cd ~/
git clone https://github.com/GoogleCloudPlatform/cloud-deploy-tutorials.git
cd cloud-deploy-tutorials
git checkout c3cae80 --quiet
cd tutorials/base

envsubst < clouddeploy-config/skaffold.yaml.template > web/skaffold.yaml
cat web/skaffold.yaml


gcloud services enable cloudbuild.googleapis.com


cd web
skaffold build --interactive=false \
--default-repo $REGION-docker.pkg.dev/$PROJECT_ID/web-app \
--file-output artifacts.json
cd ..


gcloud artifacts docker images list \
$REGION-docker.pkg.dev/$PROJECT_ID/web-app \
--include-tags \
--format yaml


cat web/artifacts.json | jq




Task 5


gcloud services enable clouddeploy.googleapis.com

gcloud config set deploy/region $REGION
cp clouddeploy-config/delivery-pipeline.yaml.template clouddeploy-config/delivery-pipeline.yaml
gcloud beta deploy apply --file=clouddeploy-config/delivery-pipeline.yaml


gcloud beta deploy delivery-pipelines describe web-app



Task 6

gcloud container clusters list --format="csv(name,status)"

CONTEXTS=("test" "staging" "prod")
for CONTEXT in ${CONTEXTS[@]}
do
    gcloud container clusters get-credentials ${CONTEXT} --region ${REGION}
    kubectl config rename-context gke_${PROJECT_ID}_${REGION}_${CONTEXT} ${CONTEXT}
done


for CONTEXT in ${CONTEXTS[@]}
do
    kubectl --context ${CONTEXT} apply -f kubernetes-config/web-app-namespace.yaml
done



for CONTEXT in ${CONTEXTS[@]}
do
    envsubst < clouddeploy-config/target-$CONTEXT.yaml.template > clouddeploy-config/target-$CONTEXT.yaml
    gcloud beta deploy apply --file clouddeploy-config/target-$CONTEXT.yaml
done



cat clouddeploy-config/target-test.yaml


cat clouddeploy-config/target-prod.yaml


gcloud beta deploy targets list




Task 7


gcloud beta deploy releases create web-app-001 \
--delivery-pipeline web-app \
--build-artifacts web/artifacts.json \
--source web/


gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001


kubectx test
kubectl get all -n web-app




Task 8



gcloud beta deploy releases promote \
--delivery-pipeline web-app \
--release web-app-001



gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001



Task 9

gcloud beta deploy releases promote \
--delivery-pipeline web-app \
--release web-app-001


gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001



gcloud beta deploy rollouts approve web-app-001-to-prod-0001 \
--delivery-pipeline web-app \
--release web-app-001



gcloud beta deploy rollouts list \
--delivery-pipeline web-app \
--release web-app-001



kubectx prod
kubectl get all -n web-app





