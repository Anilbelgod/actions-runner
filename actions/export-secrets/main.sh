#!/bin/bash

SECRETS_FILE="$1"
APP_NAME="$2"
SERVICE_NAME="$3" 
VAULT_ENV_KEYS="$4"


while IFS=: read -r key; do
 
  SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${key}"
  secret_value=$(gcloud secrets versions access latest --secret="$SECRET_NAME") 

  echo "${key}: ${secret_value}" >> "$SECRETS_FILE"
  
done < "$VAULT_ENV_KEYS"