#!/bin/bash

SECRETS_FILE="$1"
APP_NAME="$2"
SERVICE_NAME="$3" 
TEMP_SECRET_FILE="$4"  

echo "Printing secrets file: $SECRETS_FILE" 


# while IFS=: read -r key value; do
 
#   SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${key}"
  

#   if ! gcloud secrets describe "$SECRET_NAME" >/dev/null 2>&1; then
#     echo "Creating secret: $SECRET_NAME"
#     gcloud secrets create "$SECRET_NAME"  
#   fi 

#   echo "$value" > $TEMP_SECRET_FILE  
#   echo "Adding version to secret: $SECRET_NAME"
#   gcloud secrets versions add "$SECRET_NAME" --data-file=$TEMP_SECRET_FILE 


# done < "$SECRETS_FILE" 