export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=us-central1
gcloud config set compute/region $REGION


gcloud services enable \
cloudresourcemanager.googleapis.com \
container.googleapis.com \
sourcerepo.googleapis.com \
cloudbuild.googleapis.com \
containerregistry.googleapis.com \
run.googleapis.com



gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
--role=roles/run.admin



gcloud iam service-accounts add-iam-policy-binding \
$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
--member=serviceAccount:$PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
--role=roles/iam.serviceAccountUser




git config --global user.email "[YOUR_EMAIL_ADDRESS]"
git config --global user.name "[YOUR_USERNAME]"



git clone https://github.com/GoogleCloudPlatform/software-delivery-workshop --branch cloudrun-progression-csr cloudrun-progression
cd cloudrun-progression/labs/cloudrun-progression
rm -rf ../../.git



sed "s/PROJECT/${PROJECT_ID}/g" branch-trigger.json-tmpl > branch-trigger.json
sed "s/PROJECT/${PROJECT_ID}/g" master-trigger.json-tmpl > master-trigger.json
sed "s/PROJECT/${PROJECT_ID}/g" tag-trigger.json-tmpl > tag-trigger.json



gcloud source repos create cloudrun-progression
git init
git config credential.helper gcloud.sh
git remote add gcp https://source.developers.google.com/p/$PROJECT_ID/r/cloudrun-progression
git branch -m master
git add . && git commit -m "initial commit"
git push gcp master





Task 2


gcloud builds submit --tag gcr.io/$PROJECT_ID/hello-cloudrun
gcloud run deploy hello-cloudrun \
--image gcr.io/$PROJECT_ID/hello-cloudrun \
--platform managed \
--region $REGION \
--tag=prod -q



PROD_URL=$(gcloud run services describe hello-cloudrun --platform managed --region $REGION --format=json | jq --raw-output ".status.url")
echo $PROD_URL
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" $PROD_URL





Task 3






gcloud beta builds triggers create cloud-source-repositories --trigger-config branch-trigger.json



git checkout -b new-feature-1


edit app.py



Make small changes in editor *watch video*



git add . && git commit -m "updated" && git push gcp new-feature-1








BRANCH_URL=$(gcloud run services describe hello-cloudrun --platform managed --region $REGION --format=json | jq --raw-output ".status.traffic[] | select (.tag==\"new-feature-1\")|.url")
echo $BRANCH_URL


curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" $BRANCH_URL





Task 4 



gcloud beta builds triggers create cloud-source-repositories --trigger-config master-trigger.json


git checkout master
git merge new-feature-1
git push gcp master





Task 5

gcloud beta builds triggers create cloud-source-repositories --trigger-config tag-trigger.json

git tag 1.1
git push gcp 1.1




