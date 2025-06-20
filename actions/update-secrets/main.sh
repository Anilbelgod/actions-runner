#!/bin/bash

APP_NAME="$1"
ENVIRONMENT="$2" 
SECRETS_FILE="$3"
TEMP_SECRET_FILE="$4"  

echo >> "$SECRETS_FILE" 


while IFS=: read -r key value; do
 
  # Skip if key is empty or just whitespace
  if [[ -z "${key// }" ]]; then
    continue
  fi
  
  SECRET_NAME="service-${APP_NAME}-secret-${ENVIRONMENT}-${key}"
  
  if ! gcloud secrets describe "$SECRET_NAME" >/dev/null 2>&1; then
    echo "Creating secret: $SECRET_NAME"
    gcloud secrets create "$SECRET_NAME"  
  fi 

  echo "$value" > $TEMP_SECRET_FILE  
  echo "Adding version to secret: $SECRET_NAME"
  gcloud secrets versions add "$SECRET_NAME" --data-file=$TEMP_SECRET_FILE 


done < "$SECRETS_FILE" 