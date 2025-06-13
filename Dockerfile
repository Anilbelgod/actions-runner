# https://github.com/cloudposse/geodesic/
ARG GEODESIC_VERSION=3.1.0
ARG GEODESIC_OS=debian
# https://github.com/cloudposse/atmos
ARG ATMOS_VERSION=1.86.2

# This should match the version set in .github/workflows/pre-commit.yaml
ARG TF_1_VERSION=1.7.4
# Install the version of Kubectl that matches (within 1) the version of the EKS cluster.
# See stacks/catalog/eks.yaml
ARG KUBECTL_VERSION=1.29

FROM cloudposse/geodesic:${GEODESIC_VERSION}-${GEODESIC_OS}

# Geodesic message of the Day
ENV MOTD_URL="https://geodesic.sh/motd"

# Some configuration options for Geodesic
ENV GEODESIC_TF_PROMPT_ACTIVE=false
ENV DIRENV_ENABLED=false


# Install the version of Kubectl that matches the version of the EKS cluster
ARG KUBECTL_VERSION
RUN apt-get update && apt-get install -y -u --allow-downgrades \
    kubectl-${KUBECTL_VERSION}


# Install Terraform

ARG TF_1_VERSION
RUN wget "https://releases.hashicorp.com/terraform/${TF_1_VERSION}/terraform_${TF_1_VERSION}_linux_amd64.zip" && \
    unzip "terraform_${TF_1_VERSION}_linux_amd64.zip" -d /usr/local/bin && \
    rm "terraform_${TF_1_VERSION}_linux_amd64.zip"

# https://github.com/Versent/saml2aws#linux
ARG ATMOS_VERSION
RUN apt-get update && apt-get install -y --allow-downgrades \
    atmos="${ATMOS_VERSION}-*" \
    google-cloud-sdk \
    google-cloud-cli-gke-gcloud-auth-plugin

# Install NumPy which is used to increase the performance of the SSH tunnel to a bastion host
RUN $(gcloud info --format="value(basic.python_location)") -m pip install numpy  

#COPY rootfs/ /


ARG DOCKER_REPO
ARG TENANT="core"
ENV NAMESPACE=cch
# Format of Geodesic banner prompt
ENV BANNER="CareCloud Health GCP"
ENV DOCKER_IMAGE="${NAMESPACE}/infra"
ENV DOCKER_TAG="latest"

# Install TFLint
ENV TFLINT_VERSION="0.50.3"

RUN wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip && \
    unzip tflint_linux_amd64.zip -d /usr/local/bin && \
    rm tflint_linux_amd64.zip

# Install Checkov
RUN pip install checkov


WORKDIR /
