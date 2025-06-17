# Declare variables to resolve the warnings
variable "environment" {
  description = "The deployment environment (e.g., dev, prod)."
  type        = string
}

variable "namespace" {
  description = "A namespace for organizing resources."
  type        = string
}

# Add these blocks to your main.tf or variables.tf file

variable "tenant" {
  description = "The tenant associated with the resources."
  type        = string
  # You can add a default value if you want, e.g., default = "default-tenant"
}

variable "stage" {
  description = "The deployment stage (e.g., dev, test, prod)."
  type        = string
  # You can add a default value if you want, e.g., default = "dev"
}

# --- Generic Google Cloud Storage Bucket ---

resource "google_storage_bucket" "generic_bucket" {

  project = "cch-plat-gbl-dev-de0b9019"
  name = "globally-unique-bucket-name-raj-cch"
  location = "US-CENTRAL1"
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }

  force_destroy = false
  labels = {
    env      = "development"
    origin   = "terraform"
  }
}




