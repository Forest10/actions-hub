#!/bin/sh -l

set -e


# check values
if [ -z "${GITHUB_REF}" ]; then
    echo "You must provide the action with GITHUB_REF in order to deploy."
    exit 1
fi
if [ -z "${GITHUB_USERNAME}" ]; then
    echo "You must provide the action with GITHUB_USERNAME in order to deploy."
    exit 1
fi
if [ -z "${GITEE_REF}" ]; then
    echo "You must provide the action with GITEE_REF in order to deploy."
    exit 1
fi
if [ -z "${PRIVATE_GITHUB_TOKEN}" ]; then
    echo "You must provide the action with PRIVATE_GITHUB_TOKEN in order to deploy."
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
git clone https://${GITEE_USERNAME}:${GITEE_TOKEN}@${GITEE_REF}  giteeTmp
git clone https://${PRIVATE_GITHUB_TOKEN}@${GITHUB_REF}  githubTmp


cd ./githubTmp
git pull
cd ../giteeTmp
git pull
# 把github的文件全量复制到gitee中
cp -R  ../githubTmp/* ./
# 设置用户名mail
git config user.name "Forest10"
git config user.email ${PUBLISH_EMAIL}
echo 'date' > today.txt
# 进入gitee 开始操作
git add .
git commit -m "Sync From GitHub By sync-2-gitee action"t
# push to GITEE
git push
