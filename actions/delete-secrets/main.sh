#!/bin/bash

APP_NAME="$1"
SERVICE_NAME="$2"
DELETE_ALL="$3"
VAULT_ENV_KEYS="$4"
TEMP_SECRETS_FILE="$5"


gcloud secrets list \
  --filter="name~'${APP_NAME}-${SERVICE_NAME}-.*'" \
  --format="value(name)" > $TEMP_SECRETS_FILE 



