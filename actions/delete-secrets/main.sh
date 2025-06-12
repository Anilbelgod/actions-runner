#!/bin/bash

APP_NAME="$1"
SERVICE_NAME="$2"
DELETE_ALL="$3"
DELETE_ALL_EXCEPT_KEYS="$4"

TEMP_SECRETS_FILE="$5"

GCS_BUCKET_PATH="gs://cch-cicd-test-bucket/temp"
gsutil cp "$TEMP_SECRETS_FILE" "$GCS_BUCKET_PATH"

#Get all the secrets for the given app and service 
gcloud secrets list \
--filter="name~'${APP_NAME}-${SERVICE_NAME}-.*'" \
--format="value(name)" > "$TEMP_SECRETS_FILE" 

#Getting existing secrets count.
existing_keys=()
while IFS= read -r secret_name; do
    if [ -n "$secret_name" ]; then
        existing_keys+=("$secret_name")
    fi
done < "$TEMP_SECRETS_FILE"

existing_key_count=${#existing_keys[@]}

echo "$existing_key_count existing key(s) found"

#Deleting process

if [ ! -z "$DELETE_ALL" ] && [ "$DELETE_ALL" == "true" ]; then
    echo "Deleting all keys"

    for key in "${existing_keys[@]}"; do
        SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${key}"
        echo "Deleting key: $SECRET_NAME"

        gcloud secrets delete "$SECRET_NAME" --quiet
    done

    echo "Deleted all keys"
elif [ ! -z "$DELETE_ALL_EXCEPT_KEYS" ]; then
    echo "Deleting all except specific keys"

    for existing_key in "${existing_keys[@]}"; do
        keep_key=0
        for except_key in $DELETE_ALL_EXCEPT_KEYS; do
            if [ "$except_key" == "$existing_key" ]; then
                keep_key=1
                break
            fi
        done

        if [ $keep_key -eq 0 ]; then
            SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${existing_key}"
            echo "Deleting key: $SECRET_NAME"
            gcloud secrets delete "$SECRET_NAME" --quiet
        else
            echo "Keep key: ${existing_key}"
        fi
    done

    echo "Deleted all except specific keys"
else
    echo "No deletes requested because DELETE_ALL is not 'true' and no keys were specified in DELETE_ALL_EXCEPT_KEYS"
fi
