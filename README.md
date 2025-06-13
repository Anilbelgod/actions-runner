# cch-gcp-infra
CareCloud Health GCP Infrastructure

This repository defines the cch infrastructure developed
with [Qarik](https://www.qarik.com/) in 1H2024.

Key components:

* [Terraform](https://www.terraform.io/),
    [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_code)
    recipes/templates

* [Atmos](https://atmos.tools/) a tool for authoring and wrangling Terraform at scale

* [Kubernetes (k8s)](https://kubernetes.io/) container-driven, cloud-native
    cluster and application/workload platform

* [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine)
    Google's managed Kubenetes-as-a-service platform

## Table of Contents

* [Secure Landing Zone](https://github.com/CareCloud/cch-gcp-infra/blob/main/README.md)
* [Documentation](https://github.com/CareCloud/cch-gcp-infra/tree/main/docs)
    * [ADR](https://github.com/CareCloud/cch-gcp-infra/tree/main/docs/adr)
    * [Guides](https://github.com/CareCloud/cch-gcp-infra/tree/feature/documentation/docs/guides)
        * [cch-brez](https://github.com/CareCloud/cch-gcp-infra/blob/feature/documentation/docs/guides/CCH-BREZ.md)
        * [cch-edi](https://github.com/CareCloud/cch-gcp-infra/blob/feature/documentation/docs/guides/CCH-EDI.md)
        * [cch-ehr](https://github.com/CareCloud/cch-gcp-infra/blob/feature/documentation/docs/guides/CCH-EHR.md)
        * [cch-plat](https://github.com/CareCloud/cch-gcp-infra/blob/feature/documentation/docs/guides/CCH-PLAT.md)
    * [Templates](https://github.com/CareCloud/cch-gcp-infra/tree/feature/documentation/docs/templates)
        * [ADR Template](https://github.com/CareCloud/cch-gcp-infra/blob/feature/documentation/docs/templates/ADR-TEMPLATE.md)
        * [App Template](https://github.com/CareCloud/cch-gcp-infra/blob/feature/documentation/docs/templates/APP-TEMPLATE.md)

## Quick start

## GitHub Actions (GHA) Pipeline

Deployments are orchestrated through a GitHub Actions Pipeline, performing the following steps:

1. **Secscan**: Runs security scans to ensure Terraform code adheres to best practices in a Terraform and Google Cloud Platform (GCP) context.
2. **Atmos-plan-apply**: Executes an Atmos workflow based on the modified folder for deploying new code. This includes "atmos validate," "atmos terraform plan," and "atmos terraform apply."
   - Note: The apply step runs only when merged to the main branch. Feature branches and pull requests trigger GHA without the apply step.

For updates to existing stacks with deployed IaC on GCP, no changes to Atmos workflows should be necessary. For new code creating a new stack, follow these steps:

1. Create or update a YAML file in the workflow directory outlining the steps to plan and apply the new stack.
2. Review the main workflow file related to the mentioned steps, ensuring it runs the components for your workflow.

### Authentication to GCP

In the [atmos-terraform.yaml](https://github.com/CareCloud/cch-gcp-infra/blob/main/.github/workflows/atmos-terraform.yaml), the GHA workflow is configured to authenticate with Workload Identity Federation (WIF):

```sh
- name: Authenticate to Google Cloud
        id: auth
        uses: google-github-actions/auth@v1
        with:
            workload_identity_provider: 'projects/150506770475/locations/global/workloadIdentityPools/cch-github-terraformer/providers/cch-gh-actions'
            service_account: 'cch-tf-sa@cch-seed.iam.gserviceaccount.com'
```
This is the mapping provided for Terraform to authenticate by impersonating a service account with the permissions Terraform needs to deploy resources. This allows for tokenless authentication, providing a more secure method of connection. The creation and management of WIF is all managed in the [cc-gcp-repo](https://github.com/CareCloud/cc-gcp-infra) as IaC. To see the configuration, you must have access to this repo where you will see the [seed-cch.tf](https://github.com/CareCloud/cc-gcp-infra/blob/main/terraform/seed-cch.tf) configuration file. This file should not be altered unless you are authorized to make change at the CareCloud orginization level. 

For information on how GitHub Actions passes authentication to Terraform to authenticate to GCP using Workload Identity Federation, please refer to this [Workload Identity documentation](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines).

## Repository Organization Structure

The following diagram is meant to be a high level description of the intent of folders and the
configuration contained within them.  This primarily follows the
[Organizational Structure Configuration](https://atmos.tools/design-patterns/organizational-structure-configuration)
pattern.


```
 │ 
 ├── components
 │   └── terraform  # Terraform components (a.k.a Terraform "root" modules)
 │  
 └── stacks
     ├── catalog  # component-specific defaults
     ├── mixins
     │   ├── tenant  # tenant-specific defaults
     │   │   └── _defaults.yaml
     │   ├── region  # region-specific defaults
     │   │   └── us-central1.yaml
     │   └── stage  # stage-specific defaults
     │       └── prod.yaml
     └── orgs  # Organizations
         └── cch
             ├── _defaults.yaml
             ├── core  # tenant
             │   ├── _defaults.yaml # tenant defaults
             │   └── auto
             │       ├── _defaults.yaml # stage defaults
             │       └── us-central1
             │           └── component.yaml # tenant-env-stage overrides
             └── plat  # tenant
                 ├── _defaults.yaml
                 └── prod
                     ├── _defaults.yaml
                     └── us-central1
                         └── component.yaml # tenant-env-stage overrides
```

## Stacks
The list below is not inclusive of all that we may eventually have:

Stack Naming Convention: TENANT-ENVIRONMENT-STAGE

TENANTS
- plat
- brez
- edi
- ehr
- core

ENVIRONMENTS
- gbl
- usc1

STAGES
For product tenants
- sandbox
- dev
- stage
- prod

For core tenant:
- auto
- artifact
- corp
- dns
- network_sandbox
- network_dev
- network_staging
- network_prod
- audit
- security

## Geodesic Shell

[Geodesic](https://docs.cloudposse.com/tutorials/geodesic-getting-started/) is a cloud automation shell. It's the
fastest way to get up and running with a rock solid, production grade cloud platform built on top of strictly Open
Source tools.

First terminal:

In the root path of this repo execute the Geodesic container by running

```sh
make all
```

Inside of the container, authenticate with GCP for Terraform access
```sh
gcloud auth application-default login --project cch-seed
```

Inside of the container, authenticate with GCP for your own gcloud commands in Geodesic
```sh
gcloud auth login --project cch-seed
```

Keep the container running on this terminal

## Configure Access to GKE

1 - Second Terminal: Open another terminal tab and connect to the Geodesic container
```sh
docker exec -it $(docker ps -aqf "name=^cch-gcp-infra$") bash
```

2 - Second Terminal: Setup GKE network connection for kubectl. This is the "replacement" for a VPN.
**Update the project based on your target (you need to use the GCP project ID (NOT THE NAME)**
```sh
gcloud compute ssh iap-gke-bastion --zone=us-east4-a --project=cch-ehr-gbl-dev-nly --tunnel-through-iap  --ssh-flag="-4 -L8888:localhost:8888 -q -N -n -T"

or 

gcloud compute ssh iap-gke-bastion --zone=us-east4-a --project=cch-core-gbl-auto-v1u --tunnel-through-iap  --ssh-flag="-4 -L8888:localhost:8888 -q -N -n -T"
```

3 - First Terminal: Set the HTTPS Proxy for Kubectl to work, run this from inside the container
```sh
export HTTPS_PROXY="http://localhost:8888"
```

4 - First Terminal: Configure Kubectl for the target cluster
**Update the project and cluster based on your target (you need to use the cluster name and the project ID (NOT NAME)**
```sh
gcloud container clusters get-credentials cch-ehr-use4-dev-gke --region us-east4 --project cch-ehr-gbl-dev-nly

or 

gcloud container clusters get-credentials cch-core-use4-auto-gke --region us-east4 --project cch-core-gbl-auto-v1u
```

5 - First Terminal: Test your connection to the cluster
```sh
kubectl get namespaces
```
6 - First terminal, test your terraform commands for the project you authenticated with

```sh
atmos terraform plan gke -s brez-gbl-dev
```

### Full Setup

1. Manually installed pre-requisites
* homebrew
* docker

2. Install local host project dependencies

```sh
brew bundle
pre-commit install
```

3. Building geodesic

    ```sh
    export PATH=$HOME/.local/bin:$PATH
    ```

    For all architectures run this to build geodesic binary equal to the `APP_NAME` in the `Makefile`.

    NOTE: The `sudo` command should not be needed. This should install the geodesic binary to
    `/usr/local/bin` on non-M1 and to `~/.local/bin` on M1.

    ```sh
    make all
    ```

    Once inside the shell, `/localhost` refers to the user's `$HOME` on the host machine which is added as a symbolic link to `/localhost`, so absolute paths on the host, for example `/Users/fred/Documents`,
    will also work inside the shell, as long as they refer to files and directories under `$HOME`.
    Navigate to `/localhost` as you would `~/` to access the files as represented on the host machine; this is useful for development.

    It is a good practice to rebuild the image when starting a new branch from `main` where package updates
    could have occurred.

3. The shell can be started without building by running:

    ```sh
    make run
    ```

    or

    ```sh
    carecloud
    ```

## Notable Documents

### Architectural Decision Records

This is a collection of architectural decision records in the
[Markdown Architectural Decision Records](https://adr.github.io/madr/) format.

[Architectural Decision Records](docs/adr#architecture-decision-records)


