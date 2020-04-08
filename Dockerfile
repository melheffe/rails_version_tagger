FROM alpine
LABEL "repository"="https://github.com/melheffe/rails_version_tagger"
LABEL "homepage"="https://github.com/melheffe/rails_version_tagger"
LABEL "maintainer"="Chris Rodriguez"

COPY entrypoint.sh /entrypoint.sh

RUN apk update && apk add bash git curl jq

ENTRYPOINT ["/entrypoint.sh"]