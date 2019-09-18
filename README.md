# Update all Cloud Foundry buildpacks

As a Cloud Foundry platform operator, I want to ensure my users/developers always have the latest upstream buildpacks, with the latest CVEs, for their applications.

```plain
# 1. cf login as an admin
# 2. run this script
curl https://raw.githubusercontent.com/starkandwayne/update-all-cf-buildpacks/master/update-only.sh | bash
```

## Docker

The dependencies and script are packaged in a Docker image and can be run.

For example, to run against a [fresh CF Eirini environment](https://github.com/starkandwayne/bootstrap-gke#cloud-foundry--eirini--quarks):

```plain
docker run -ti \
    -e CF_API=https://api.scf.suse.dev \
    -e CF_SKIP_SSL_VALIDATION=true \
    -e CF_USERNAME=admin \
    -e CF_PASSWORD="$(kubectl get secret -n scf scf.var-cf-admin-password -o json | jq -r .data.password | base64 --decode)" \
  starkandwayne/update-all-cf-buildpacks
```

## Data only

This project also curates a [`buildpacks.json`](https://github.com/starkandwayne/update-all-cf-buildpacks/blob/master/buildpacks.json) file that contains the URLs for the latest buildpacks for each project:

```plain
curl https://raw.githubusercontent.com/starkandwayne/update-all-cf-buildpacks/master/buildpacks.json
```

## CI pipeline

The `update-only.sh` and `buildpacks.json` files are automatically updated via a CI pipeline:

* https://ci2.starkandwayne.com/teams/cfcommunity/pipelines/update-all-cf-buildpacks

The Concourse CI pipeline definition is in `ci/pipeline.yml`.
