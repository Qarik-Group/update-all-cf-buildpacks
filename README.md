# Update all Cloud Foundry buildpacks

As a Cloud Foundry platform operator, I want to ensure my users/developers always have the latest upstream buildpacks, with the latest CVEs, for their applications.

```plain
# 1. cf login as an admin
# 2. run this script
curl -L https://raw.githubusercontent.com/starkandwayne/update-all-cf-buildpacks/master/update-only.sh | bash
```
