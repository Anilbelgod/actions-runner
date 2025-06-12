#!/bin/bash

SECRETS_FILE="$1"
APP_NAME="$2"
SERVICE_NAME="$3"
VAULT_ENV_KEYS="$4"

while IFS=: read -r line; do
    #Remove leading and trailing whitespace
    key=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//')

    SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${key}"

    secret_value=$(gcloud secrets versions access latest --secret="$SECRET_NAME")


    if [ $? -ne 0 ]; then
        echo "Secret not found: $SECRET_NAME — skipping."
        continue
    fi

    echo "${key}: ${secret_value}" >> "$SECRETS_FILE"
done < "$VAULT_ENV_KEYS" 

