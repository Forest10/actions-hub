#!/bin/sh -l

set -e


# check values
if [ -z "${GITHUB_REF}" ]; then
    echo "You must provide the action with GITHUB_REF in order to deploy."
    exit 1
fi
if [ -z "${GITEE_REF}" ]; then
    echo "You must provide the action with GITEE_REF in order to deploy."
    exit 1
fi

if [ -z "${GITEE_USERNAME}" ]; then
    echo "You must provide the action with GITEE_USERNAME in order to deploy."
    exit 1
fi
if [ -z "${GITEE_TOKEN}" ]; then
    echo "You must provide the action with GITEE_TOKEN in order to deploy."
    exit 1
fi


if [ -n "${EMAIL}" ]; then
    PUBLISH_EMAIL=${EMAIL}
else
    PUBLISH_EMAIL="github.forest10@gmail.com"
fi
git clone ${GITHUB_REF} githubTmp
git clone ${GITEE_USERNAME}:${GITEE_TOKEN}@${GITEE_REF}  giteeTmp
cd ./githubTmp
git pull
cd ../giteeTmp
git pull
# 把github的文件全量复制到gitee中
cp -R  ../githubTmp/* ./
# 设置用户名mail
git config user.name "Forest10"
git config user.email ${PUBLISH_EMAIL}
# 进入gitee 开始操作
git add .
git commit -m "Sync From GitHub By sync-2-gitee action"
# push to GITEE
git push
