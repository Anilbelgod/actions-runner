#!/bin/bash

APP_NAME="$1"
ENVIRONMENT="$2"
VAULT_ENV_KEYS="$3"
SECRETS_FILE="$4"

while IFS=: read -r line; do
    #Remove leading and trailing whitespace
    key=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//')

    SECRET_NAME="service-${APP_NAME}-secret-${ENVIRONMENT}-${key}"

    secret_value=$(gcloud secrets versions access latest --secret="$SECRET_NAME")


    if [ $? -ne 0 ]; then
        echo "Secret not found: $SECRET_NAME — skipping."
        continue
    fi

    echo "${key}: ${secret_value}" >> "$SECRETS_FILE"
done < "$VAULT_ENV_KEYS" 

