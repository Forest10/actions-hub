#!/bin/bash -l

set -e

# check values
if [ -z "${GITHUB_REPOSITORY}" ]; then
  echo "You must provide the action with GITHUB_REPOSITORY in order to deploy. like Forest10/test"
  exit 1
fi
if [ -z "${GITEE_HTTPS_REF}" ]; then
  echo "You must provide the action with GITEE_HTTPS_REF in order to deploy.like gitee.com/Forest10/testSync"
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

# put default
if [ -n "${EMAIL}" ]; then
  PUBLISH_EMAIL=${EMAIL}
else
  PUBLISH_EMAIL="github.forest10@gmail.com"
fi
git clone https://${PRIVATE_GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git githubTmp
git clone https://${GITEE_USERNAME}:${GITEE_TOKEN}@${GITEE_HTTPS_REF}.git giteeTmp
cd ./giteeTmp
# 设置用户名mail
git config user.name "Forest10"
git config user.email ${PUBLISH_EMAIL}
git fetch
giteeBranchArray=$(git branch -r | grep -v -- '->' | cut -f 2 -d "/")
echo "giteeBranchArray": ${giteeBranchArray}
## 进入GitHubtmp
cd ../githubTmp
git fetch
###获取github当前分支名称
githubNowBranch=$(git symbolic-ref --short -q HEAD)
##如果是master
if [ "$githubNowBranch"x = "master"x ]; then
  echo 'github now in master'
  ###获取所有分支
  for b in $(git branch -r | grep -v -- '->'); do
    branchName=${b#*/}
    git checkout ${branchName}
    git pull
    cd ../giteeTmp
    # POSIX
    if [[ $giteeBranchArray == *$branchName* ]]; then
      git checkout ${branchName}
      git branch --set-upstream-to=origin/${branchName} ${branchName}
      git pull
    else
      git checkout -b ${branchName}
    fi
    # 把github的文件全量复制到otherGitTmp中
    cp -R ../githubTmp/* ./
    # 进入 other git 开始操作
    echo $(date) >today.txt
    git add .
    git commit -m "Sync From GitHub By sync-2-gitee action"
    # push to gitee
    git push --set-upstream origin ${branchName}
    cd ../githubTmp
  done
  exit 0
fi

cd ./githubTmp
git pull
cd ../giteeTmp
git pull
# 把github的文件全量复制到otherGitTmp中
cp -R ../githubTmp/* ./
# 进入 other git 开始操作
echo $(date) >today.txt
git add .
git commit -m "Sync From GitHub By sync-2-gitee action"
# push to gitee
git push

git checkout -b branch_name
