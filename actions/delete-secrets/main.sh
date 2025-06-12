#!/bin/bash

APP_NAME="$1"
SERVICE_NAME="$2"
DELETE_ALL="$3"
DELETE_ALL_EXCEPT_KEYS="$4"

TEMP_SECRETS_FILE="$5"

#Get all the secrets for the given app and service 
gcloud secrets list \
--filter="name~'${APP_NAME}-${SERVICE_NAME}-.*'" \
--format="value(name)" > "$TEMP_SECRETS_FILE" 

GCS_BUCKET_PATH="gs://cch-cicd-test-bucket/temp"
gsutil cp "$TEMP_SECRETS_FILE" "$GCS_BUCKET_PATH"

gsutil cp "$DELETE_ALL_EXCEPT_KEYS" "$GCS_BUCKET_PATH" 
#Getting existing secrets count.
existing_keys=()
while IFS= read -r secret_name; do
    if [ -n "$secret_name" ]; then
        existing_keys+=("$secret_name")
    fi
done < "$TEMP_SECRETS_FILE"

existing_key_count=${#existing_keys[@]}

echo "$existing_key_count existing key(s) found"

echo "Existing keys:" 
cat $existing_keys
#Deleting process

if [ ! -z "$DELETE_ALL" ] && [ "$DELETE_ALL" == "true" ]; then
    echo "Deleting all keys"

    for key in "${existing_keys[@]}"; do

        echo "Deleting key: $key"

        gcloud secrets delete "$key" --quiet
    done

    echo "Deleted all keys"
elif [ ! -z "$DELETE_ALL_EXCEPT_KEYS" ]; then
    echo "Deleting all except specific keys"

    for existing_key in "${existing_keys[@]}"; do
        keep_key=0
        for except_key in $DELETE_ALL_EXCEPT_KEYS; do
            key=$(echo "$except_key" | sed 's/^[[:space:]]*-[[:space:]]*//') 
            echo "Printing key: ${key}" 
            SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${key}"
            echo "Printing Secret Name: ${SECRET_NAME}"
            echo "Printing existing key: ${existing_key}" 
            if [ "$SECRET_NAME" == "$existing_key" ]; then
                keep_key=1
                break
            fi
        done

        if [ $keep_key -eq 0 ]; then
            # SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${existing_key}"
            echo "Deleting key: ${existing_key}"
            gcloud secrets delete "$existing_key" --quiet
        else
            echo "Keep key: ${existing_key}"
        fi
    done

    echo "Deleted all except specific keys"
else
    echo "No deletes requested because DELETE_ALL is not 'true' and no keys were specified in DELETE_ALL_EXCEPT_KEYS"
fi
