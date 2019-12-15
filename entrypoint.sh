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
if [ -n "${QSHELL_HOME}" ]; then
    ACTION_QSHELL_HOME=${QSHELL_HOME}
else
    ACTION_QSHELL_HOME="/home/runner/.qshell"
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

echo "Deployment to git succesful!"

echo "Start del .git"
rm -rf .git
echo "del .git ok!"


PUBLIC_DIR_PATH=`pwd`
echo "退回上一层目录!"
cd ../
QSHELL_DIR_PATH=`pwd`
echo "Start setup qshell!"
wget http://devtools.qiniu.com/qshell-linux-x64-v2.4.0.zip -O qshell.zip
unzip qshell.zip
mv qshell-linux-x64-v2.4.0 qshell
chmod u+x qshell
echo "setup qshell done!"
#
#echo "退回到${ACTION_QSHELL_HOME}!"
#
#cd $ACTION_QSHELL_HOME
echo 'Start get qshell cache from git'
git clone https://$PERSONAL_TOKEN@github.com/${QINIU_LOCAL_CACHE_GIT_REPOSITORY}.git
git checkout ${QINIU_LOCAL_CACHE_GIT_REPOSITORY_BRANCH}
git pull

cd ${QSHELL_DIR_PATH}
echo 'Start run qshell account'
./qshell account ${QINIU_AK} ${QINIU_SK} ${QINIU_USER_NAME}
echo 'Start run locate .qshell'
locate .qshell
#
#echo 'Start run qshell upload2'
###增量更新上传(外加多线程)
#./qshell qupload2  --overwrite --src-dir=${PUBLIC_DIR_PATH}/ --bucket=${QINIU_BUCKET}  --rescan-local --thread-count 16
#echo 'done  upload qiniu'
#echo 'qiniu upload2 cache to git'
###加入不报错 就把当前的变化直接传送到git上
#cd $ACTION_QSHELL_HOME
#git add .
#git commit -m "transfer local upload2 cache to git"
#git push
#echo 'qiniu upload2 cache to git done!'






