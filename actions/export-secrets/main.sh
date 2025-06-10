#!/bin/bash

# --- Strict Mode ---
# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipelines return the exit status of the last command to fail.
set -o pipefail

# --- Argument Validation ---
# Ensure all four required arguments are provided.
if [ "$#" -ne 4 ]; then
    # Print usage message to standard error.
    echo "Usage: $0 <secrets_file> <app_name> <service_name> <keys_file>" >&2
    exit 1
fi

# --- Assign Arguments to Variables ---
SECRETS_FILE="$1"
APP_NAME="$2"
SERVICE_NAME="$3"
VAULT_ENV_KEYS="$4"

# --- Main Logic ---
# Read the file line by line to get each key.
# 'IFS=' prevents leading/trailing whitespace from being trimmed.
# '-r' prevents backslash escapes from being interpreted.
while IFS= read -r key; do
  # Skip any empty lines in the input file to prevent errors.
  if [ -z "$key" ]; then
    continue
  fi

  # Construct the full secret name for Google Cloud Secrets Manager.
  SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${key}"
  echo "Attempting to fetch secret: ${SECRET_NAME}" >&2

  # Fetch the latest version of the secret.
  # The 'set -e' at the top will cause the script to exit immediately
  # if this gcloud command fails (e.g., secret not found, no permission).
  secret_value=$(gcloud secrets versions access latest --secret="${SECRET_NAME}")

  # Append the key and its fetched value to the output file in YAML format.
  echo "${key}: ${secret_value}" >> "$SECRETS_FILE"

done < "$VAULT_ENV_KEYS"

echo "Script finished. Secrets written to ${SECRETS_FILE}" >&2

# SECRETS_FILE="$1"
# APP_NAME="$2"
# SERVICE_NAME="$3" 
# VAULT_ENV_KEYS="$4"


# while IFS=: read -r key; do
 
#   SECRET_NAME="${APP_NAME}-${SERVICE_NAME}-${key}"
#   secret_value=$(gcloud secrets versions access latest --secret="${SECRET_NAME}") 

#   echo "${key}: ${secret_value}" >> "$SECRETS_FILE"

# done < "$VAULT_ENV_KEYS"