* cronjob sets app=update-all-cf-buildpacks on job pods
* cronjob/helm uses .Value.image overrides
* job/cronjob use init containers to wait for CF API and to login
* CI pipeline publishes Helm chart to https://helm.starkandwayne.com
