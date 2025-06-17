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

# Define the storage bucket resource
resource "google_storage_bucket" "static-site" {
  # Add your project ID here
  project       = "cch-plat-gbl-dev-de0b9019" # 👈 FIX: Add this line

  name          = "image-store.com"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors {
    origin          = ["http://image-store.com"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}






