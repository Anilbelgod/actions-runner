#!/bin/bash

SECRET_SM_PATH="$1"
VAULT_ENV_KEYS="$2"
SECRETS_FILE="$3"

while IFS=: read -r line; do
    #Remove leading and trailing whitespace
    key=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//')

    SECRET_NAME="${SECRET_SM_PATH}-${key}"

    secret_value=$(gcloud secrets versions access latest --secret="$SECRET_NAME")


    if [ $? -ne 0 ]; then
        echo "Secret not found: $SECRET_NAME ."
        echo "Creating secret: $SECRET_NAME"
        gcloud secrets create "$SECRET_NAME" 
        continue
    fi

    echo "${key}: ${secret_value}" >> "$SECRETS_FILE"
done < "$VAULT_ENV_KEYS" 

