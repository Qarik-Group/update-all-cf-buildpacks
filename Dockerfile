FROM alpine:3.10

RUN apk add --no-cache curl bash jq

# install 'cf' into /usr/bin/cf
RUN CF_CLI_VERSION=6.46.1 && \
  curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_CLI_VERSION}&source=github-rel" | tar -C /usr/bin -xvz cf

WORKDIR /workspace
ADD *.sh /workspace/

CMD [ "./update-only.sh" ]
