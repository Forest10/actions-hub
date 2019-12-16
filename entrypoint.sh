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
if  ${QINIU_FORCE_REFRESH_BUCKET} -eq 'true' ; then
    echo 'REFRESH_BUCKET'
fi
ACTION_QSHELL_HOME=~/.qshell

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
HEXO_PUBLICL_DIR=`pwd`
echo "copy CNAME if exists"
if [ -n "${CNAME}" ]; then
    echo ${CNAME} > CNAME
fi
echo "Config git ..."
# Configures Git.
HEXO_GIT_DIR=$GITHUB_WORKSPACE/hexo_git_dir
git config user.name "${PUBLISH_USER_NAME}"
git config user.email "${PUBLISH_EMAIL}"
git clone https://$PERSONAL_TOKEN@github.com/${PUBLISH_REPOSITORY}.git ${HEXO_GIT_DIR}
git remote set-branches --add origin master
cd ${HEXO_GIT_DIR}
git fetch
git pull


cp -R ${HEXO_PUBLICL_DIR}/ ${HEXO_GIT_DIR}
echo `date` > date.txt
git add .
git commit -m '哈哈'

HEXO_UPDATE_ZIP_PATH=`pwd`
HEXO_DIFF_UPDATE_FILE_NAME=hexo_diff_update.zip
git archive -o ${HEXO_DIFF_UPDATE_FILE_NAME} HEAD $(git diff --name-only HEAD"^")
echo 'Start push'
git push

echo "Deployment to git succesful!"

cd ${HEXO_UPDATE_ZIP_PATH}
UNZIP_HEXO_UPDATE_DIR=${HEXO_UPDATE_ZIP_PATH}/${NOW_TIMESTAMP}_update
mkdir -p ${UNZIP_HEXO_UPDATE_DIR}
unzip ${HEXO_DIFF_UPDATE_FILE_NAME} -d ${UNZIP_HEXO_UPDATE_DIR}

echo "回到qshell_home!"
QSHELL_DIR_PATH=$GITHUB_WORKSPACE/qshell_dir
mkdir -p ${QSHELL_DIR_PATH}
cd ${QSHELL_DIR_PATH}
echo "Start setup qshell!"
wget http://devtools.qiniu.com/qshell-linux-x64-v2.4.0.zip -O qshell.zip
unzip qshell.zip
mv qshell-linux-x64-v2.4.0 qshell
chmod u+x qshell
echo "setup qshell done!"


cd ${QSHELL_DIR_PATH}
echo 'Start run qshell account for use new ak sk'
./qshell account ${QINIU_AK} ${QINIU_SK} ${QINIU_USER_NAME}

echo 'Start run qshell upload2'
##增量更新上传(外加多线程)
./qshell qupload2 --overwrite --src-dir=${UNZIP_HEXO_UPDATE_DIR}/ --bucket=${QINIU_BUCKET} --thread-count 16
echo 'done  upload qiniu'







