#!/bin/bash

APP_NAME="$1"
SERVICE_NAME="$2"
DELETE_ALL="$3"
DELETE_ALL_EXCEPT_KEYS="$4"   # Path to file with keys like: - region
TEMP_SECRETS_FILE="$5"        # Path to file with full secret names

GCS_BUCKET_PATH="gs://cch-cicd-test-bucket/temp"

# Backup input files to GCS (optional but useful for debugging)
gsutil cp "$TEMP_SECRETS_FILE" "$GCS_BUCKET_PATH"
gsutil cp "$DELETE_ALL_EXCEPT_KEYS" "$GCS_BUCKET_PATH"

# Deletion Logic
if [ ! -z "$DELETE_ALL" ] && [ "$DELETE_ALL" == "true" ]; then
    echo "Deleting all keys"

    while IFS= read -r secret_name; do
        if [ -n "$secret_name" ]; then
            echo "Deleting key: $secret_name"
            gcloud secrets delete "$secret_name" --quiet
        fi
    done < "$TEMP_SECRETS_FILE"

    echo "Deleted all keys"

elif [ -f "$DELETE_ALL_EXCEPT_KEYS" ]; then
    echo "Deleting all except specific keys"

    while IFS= read -r existing_key; do
        if [ -z "$existing_key" ]; then
            continue
        fi

        keep_key=0

        while IFS= read -r line; do
            key=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//')
            SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${key}"

            echo "Comparing: $SECRET_NAME with $existing_key"
            if [ "$SECRET_NAME" == "$existing_key" ]; then
                keep_key=1
                break
            fi
        done < "$DELETE_ALL_EXCEPT_KEYS"

        if [ "$keep_key" -eq 0 ]; then
            echo "Deleting key: $existing_key"
            gcloud secrets delete "$existing_key" --quiet
        else
            echo "Keep key: $existing_key"
        fi
    done < "$TEMP_SECRETS_FILE"

    echo "Deleted all except specific keys"

else
    echo "No deletes requested because DELETE_ALL is not 'true' and no keys were specified in DELETE_ALL_EXCEPT_KEYS"
fi
