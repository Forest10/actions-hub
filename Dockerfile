# Container image that runs your code
FROM node:10

LABEL "com.github.actions.name"="GitHub action hub"
LABEL "com.github.actions.description"="This GitHub action will help you code more faster."
LABEL "com.github.actions.icon"="git-commit"
LABEL "com.github.actions.color"="orange"

LABEL "repository"="https://github.com/Forest10/actions-hub"
LABEL "homepage"="https://github.com/Forest10/actions-hub"
LABEL "maintainer"="Forest10"

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
