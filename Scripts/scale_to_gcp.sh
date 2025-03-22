#!/bin/bash

# GCP Configuration
PROJECT_ID="gcpvmassignment2"
ZONE="us-central1-a"
REGION="us-central1"
MACHINE_TYPE="e2-micro"
IMAGE_FAMILY="debian-11"
IMAGE_PROJECT="debian-cloud"
NETWORK="default"  # Using the default network that exists in all GCP projects

# Launch instance with timestamp in name
INSTANCE_NAME="auto-scaled-instance-$(date +%s)"

# Log file
LOG_FILE="$HOME/scaling.log"

echo "$(date): Starting instance $INSTANCE_NAME due to high resource usage" | tee -a $LOG_FILE

# Create GCP instance
gcloud compute instances create $INSTANCE_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --machine-type=$MACHINE_TYPE \
  --network-interface=network=$NETWORK \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --service-account=default \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
  --create-disk=auto-delete=yes,boot=yes,device-name=$INSTANCE_NAME,image=projects/$IMAGE_PROJECT/global/images/family/$IMAGE_FAMILY,mode=rw,size=10,type=pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=purpose=auto-scaling

# Check if instance was created successfully
if [ $? -eq 0 ]; then
  echo "$(date): Successfully launched instance $INSTANCE_NAME" | tee -a $LOG_FILE
  
  # Optional: Deploy application to new instance
  echo "$(date): Deploying application to $INSTANCE_NAME" | tee -a $LOG_FILE
  gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="sudo apt-get update && sudo apt-get install -y nginx"
else
  echo "$(date): Failed to launch instance $INSTANCE_NAME" | tee -a $LOG_FILE
fi