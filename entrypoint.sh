#!/bin/sh -l

set -e


# check values
if [ -n "${USER_NAME}" ]; then
    PUBLISH_USER_NAME=${USER_NAME}
else
    PUBLISH_USER_NAME="Forest10"
fi
if [ -n "${EMAIL}" ]; then
    PUBLISH_EMAIL=${USER_NAME}
else
    PUBLISH_EMAIL="github.forest10@gmail.com"
fi

if [ -n "${PUBLISH_REPOSITORY}" ]; then
    PRO_REPOSITORY=${PUBLISH_REPOSITORY}
else
    PRO_REPOSITORY=${GITHUB_REPOSITORY}
fi

if [ -z "$PUBLISH_DIR" ]
then
  echo "You must provide the action with the folder path in the repository where your compiled page generate at, example public."
  exit 1
fi

if [ -z "$BRANCH" ]
then
  echo "You must provide the action with a branch name it should deploy to, for example master."
  exit 1
fi

if [ -z "$PERSONAL_TOKEN" ]
then
  echo "You must provide the action with either a Personal Access Token or the GitHub Token secret in order to deploy."
  exit 1
fi

REPOSITORY_PATH="https://x-access-token:${PERSONAL_TOKEN}@github.com/${PRO_REPOSITORY}.git"

# deploy to 
echo "Deploy to ${PRO_REPOSITORY}"

# Directs the action to the the Github workspace.
cd $GITHUB_WORKSPACE 

echo "npm install ..." 
npm install


echo "Clean folder ..."
./node_modules/hexo/bin/hexo clean

echo "Generate file ..."
./node_modules/hexo/bin/hexo generate


cd $PUBLISH_DIR
echo "copy CNAME if exists"
if [ -n "${CNAME}" ]; then
    echo ${CNAME} > CNAME
fi
echo "Config git ..."

# Configures Git.
git init
git config user.name "${PUBLISH_USER_NAME}"
git config user.email "${PUBLISH_EMAIL}"
git remote add origin "${REPOSITORY_PATH}"

git checkout --orphan $BRANCH

git add --all

echo 'Start Commit'
git commit --allow-empty -m "Deploying to ${BRANCH}"

echo 'Start Push'
git push origin "${BRANCH}" --force

echo "Deployment succesful!"
