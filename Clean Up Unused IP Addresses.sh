Task 1

gcloud services enable cloudscheduler.googleapis.com



git clone https://github.com/GoogleCloudPlatform/gcf-automated-resource-cleanup.git && cd gcf-automated-resource-cleanup/

export PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
export region=us-central1
WORKDIR=$(pwd)




Task 2

cd $WORKDIR/unused-ip

export USED_IP=used-ip-address
export UNUSED_IP=unused-ip-address

gcloud compute addresses create $USED_IP --project=$PROJECT_ID --region=us-central1
gcloud compute addresses create $UNUSED_IP --project=$PROJECT_ID --region=us-central1

gcloud compute addresses list --filter="region:(us-central1)"




export USED_IP_ADDRESS=$(gcloud compute addresses describe $USED_IP --region=us-central1 --format=json | jq -r '.address')



Task 3

gcloud compute instances create static-ip-instance \
--zone=us-central1-f \
--machine-type=e2-medium \
--subnet=default \
--address=$USED_IP_ADDRESS



gcloud compute addresses list --filter="region:(us-central1)"


Task 4


cat $WORKDIR/unused-ip/function.js | grep "const compute" -A 31


Task 5

gcloud functions deploy unused_ip_function --trigger-http --runtime=nodejs12 --region=us-central1


Type 'Y' if prompted




export FUNCTION_URL=$(gcloud functions describe unused_ip_function --region=us-central1 --format=json | jq -r '.httpsTrigger.url')





Task 6


gcloud app create --region us-central

gcloud scheduler jobs create http unused-ip-job \
--schedule="* 2 * * *" \
--uri=$FUNCTION_URL \
--location=us-central1



gcloud scheduler jobs run unused-ip-job \
--location=us-central1


gcloud compute addresses list --filter="region:(us-central1)"







