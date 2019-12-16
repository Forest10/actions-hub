#!/bin/sh -l

set -e

rsync --version

#
## check values
#if [ -n "${USER_NAME}" ]; then
#    PUBLISH_USER_NAME=${USER_NAME}
#else
#    PUBLISH_USER_NAME="Forest10"
#fi
#if [ -n "${EMAIL}" ]; then
#    PUBLISH_EMAIL=${USER_NAME}
#else
#    PUBLISH_EMAIL="github.forest10@gmail.com"
#fi
#
#ACTION_QSHELL_HOME=~/.qshell
#
#if [ -n "${PUBLISH_REPOSITORY}" ]; then
#    PRO_REPOSITORY=${PUBLISH_REPOSITORY}
#else
#    PRO_REPOSITORY=${GITHUB_REPOSITORY}
#fi
#
#if [ -z "$PUBLISH_DIR" ]
#then
#  echo "You must provide the action with the folder path in the repository where your compiled page generate at, example public."
#  exit 1
#fi
#
#
#if [ -z "$PERSONAL_TOKEN" ]
#then
#  echo "You must provide the action with either a Personal Access Token or the GitHub Token secret in order to deploy."
#  exit 1
#fi
#
#REPOSITORY_PATH="https://x-access-token:${PERSONAL_TOKEN}@github.com/${PRO_REPOSITORY}.git"
#
## deploy to
#echo "Deploy to ${PRO_REPOSITORY}"
#
## Directs the action to the the Github workspace.
#cd $GITHUB_WORKSPACE
##
##echo "npm install ..."
##npm install
##
##
##echo "Clean folder ..."
##./node_modules/hexo/bin/hexo clean
##
##echo "Generate file ..."
##./node_modules/hexo/bin/hexo generate
#mkdir public
#cd $PUBLISH_DIR
#
#HEXO_PUBLICL_DIR=`pwd`
#echo "copy CNAME if exists"
#if [ -n "${CNAME}" ]; then
#    echo ${CNAME} > CNAME
#fi
#echo "Config git ..."
## Configures Git.
#HEXO_GIT_DIR=$GITHUB_WORKSPACE/hexo_git_dir
#mkdir -p ${HEXO_GIT_DIR}
#cd ${HEXO_GIT_DIR}
#git config user.name "${PUBLISH_USER_NAME}"
#git config user.email "${PUBLISH_EMAIL}"
#git clone https://$PERSONAL_TOKEN@github.com/${PRO_REPOSITORY}.git ${HEXO_GIT_DIR}
#cd ${HEXO_GIT_DIR}
#git fetch
#git pull
#
#echo `date` > date.txt
#git add -A
#git commit -m '哈哈'
#
#echo 'Start push'
#git push
#
#echo "Deployment to git succesful!"
#
#
#echo "do  rsync diff file to HEXO_UPDATE_DIR!"
#git diff HEAD  HEAD~1 --name-only
#
#
#HEXO_UPDATE_DIR=$GITHUB_WORKSPACE/hexo_update_dir_in_action
#mkdir -p ${HEXO_UPDATE_DIR}
#for i in $(git diff HEAD  HEAD~1 --name-only);do rsync  -R ${i} ${HEXO_UPDATE_DIR};done
#echo "do  rsync diff file to HEXO_UPDATE_DIR done!"
#
#
#echo "回到qshell_home!"
#QSHELL_DIR_PATH=$GITHUB_WORKSPACE/qshell_dir
#mkdir -p ${QSHELL_DIR_PATH}
#cd ${QSHELL_DIR_PATH}
#echo "Start setup qshell!"
#wget http://devtools.qiniu.com/qshell-linux-x64-v2.4.0.zip -O qshell.zip
#unzip qshell.zip
#mv qshell-linux-x64-v2.4.0 qshell
#chmod u+x qshell
#echo "setup qshell done!"
#
#
#cd ${QSHELL_DIR_PATH}
#echo 'Start run qshell account for use new ak sk'
#./qshell account ${QINIU_AK} ${QINIU_SK} ${QINIU_USER_NAME}
#
#echo 'Start run qshell upload2'
###增量更新上传(外加多线程)
#./qshell qupload2 --overwrite --src-dir=${HEXO_UPDATE_DIR}/ --bucket=${QINIU_BUCKET} --thread-count 16
#echo 'done  upload qiniu'
#
#
#
#
#
#
#
