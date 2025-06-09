#!/bin/bash

SECRETS_FILE="$1"
APP_NAME="$2"
SERVICE_NAME="$3" 


while IFS=: read -r key value; do
 
  SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${key}"
  echo "$value" > /tmp/secret
  

  if ! gcloud secrets describe "$" >/dev/null 2>&1; then
    echo "Creating secret: $SECRET_NAME"
    gcloud secrets create "$SECRET_NAME"  
  fi 

  echo "Adding version to secret: $SECRET_NAME"
  gcloud secrets versions add "$SECRET_NAME" --data-file=/tmp/secret


done < "$SECRETS_FILE" 