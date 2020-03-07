#!/bin/sh -l

set -e


# check values
if [ -z "${GITHUB_REPOSITORY}" ]; then
    echo "You must provide the action with GITHUB_REPOSITORY in order to deploy."
    exit 1
fi
if [ -z "${OTHERGITEE_HTTPS_REF}" ]; then
    echo "You must provide the action with GITEE_REF in order to deploy.like xxx.com/OTHER_GIT_USERNAME/YYY.git"
    exit 1
fi
if [ -z "${PRIVATE_GITHUB_TOKEN}" ]; then
    echo "You must provide the action with PRIVATE_GITHUB_TOKEN in order to deploy."
    exit 1
fi

if [ -z "${OTHER_GIT_USERNAME}" ]; then
    echo "You must provide the action with OTHER_GIT_USERNAME in order to deploy."
    exit 1
fi
if [ -z "${OTHER_GIT_TOKEN}" ]; then
    echo "You must provide the action with OTHER_GIT_TOKEN in order to deploy."
    exit 1
fi


if [ -n "${EMAIL}" ]; then
    PUBLISH_EMAIL=${EMAIL}
else
    PUBLISH_EMAIL="github.forest10@gmail.com"
fi
git clone https://${PRIVATE_GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git githubTmp
git clone https://${OTHER_GIT_USERNAME}:${OTHER_GIT_TOKEN}@${GITEE_REF}  otherGitTmp



cd ./githubTmp
git pull
cd ../otherGitTmp
git pull
# 把github的文件全量复制到otherGitTmp中
cp -R  ../githubTmp/* ./
# 设置用户名mail
git config user.name "Forest10"
git config user.email ${PUBLISH_EMAIL}
# 进入 other git 开始操作
echo 'date' >> today.txt
git add .
git commit -m "Sync From GitHub By sync-2-gitee action"t
# push to other GIT
git push
