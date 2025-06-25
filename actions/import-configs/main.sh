#!/bin/bash

SM_PATH="$1"
CONFIGS_FILE="$2"
# --- Main Logic ---

# 1. List secrets matching the pattern and get just the secret_id (short name)
CONFIG_NAMES=$(gcloud secrets list \
  --filter="name~'${SM_PATH}-.*'" \
  --format="value(name)")


# 2. Iterate through each short secret name, fetch its latest version, and format
for CONFIGS in $CONFIG_NAMES; do
  # Extract the last part of the secret name (e.g., db-password from service-my-app-secret-dev-db-password)
  # This regex is now applied to the short secret name.
  CONFIG_KEY=$(echo "$CONFIGS" | sed -E "s/${SM_PATH}-//")

  echo "Fetching secret: $CONFIGS value"

  # Fetch the latest version of the secret.
  # Note: `gcloud secrets versions access` expects the `SECRET_FULL_NAME` or `SECRET_SHORT_NAME` for `--secret`.
  # The --secret parameter can take either the full path or just the secret ID.
  SECRET_VALUE=$(gcloud secrets versions access latest \
    --secret="$CONFIGS" \
    --quiet | tr -d '\n')

  # Append the key-value pair to the YAML file using yq
  yq eval -i ".${CONFIG_KEY} = ${SECRET_VALUE}" "$CONFIGS_FILE"
done

echo "Secrets successfully written to $CONFIGS_FILE"

GCS_BUCKET_PATH="gs://cch-cicd-test-bucket/test"
echo "Copying config file"
gsutil cp $CONFIGS_FILE "$GCS_BUCKET_PATH"

cat $CONFIGS_FILE # Optional: Display the content of the generated YAML