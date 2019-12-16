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
cd ${HEXO_GIT_DIR}
git fetch
git pull


cp -R ${HEXO_PUBLICL_DIR}/ ${HEXO_GIT_DIR}
echo `date` > date.txt
git add .
git commit -m '哈哈'
echo 'git diff  start'
git diff --name-only > git_diff.txt
ls
cat git_diff.txt
echo 'git diff  end'

HEXO_PUBLICL_FILE_DIFF_FILE=`date +%s`.txt
touch ${HEXO_PUBLICL_FILE_DIFF_FILE}
chmod 777 ${HEXO_PUBLICL_FILE_DIFF_FILE}
git diff --name-only > ${HEXO_PUBLICL_FILE_DIFF_FILE}
echo 'cat ${HEXO_PUBLICL_FILE_DIFF_FILE}'
cat ${HEXO_PUBLICL_FILE_DIFF_FILE}
NEED_REWRITE_QINIU_FILE=`cat ${HEXO_PUBLICL_FILE_DIFF_FILE} | xargs`
echo 'cat ${NEED_REWRITE_QINIU_FILE}'
cat ${NEED_REWRITE_QINIU_FILE}
echo 'Start push'
git push

echo "Deployment to git succesful!"

echo "Start del .git"
rm -rf .git
echo "del .git ok!"


echo "退回上一层目录!"
cd ${HEXO_PUBLICL_DIR}/../
QSHELL_DIR_PATH=`pwd`
echo "Start setup qshell!"
wget http://devtools.qiniu.com/qshell-linux-x64-v2.4.0.zip -O qshell.zip
unzip qshell.zip
mv qshell-linux-x64-v2.4.0 qshell
chmod u+x qshell
echo "setup qshell done!"

echo "Start get qshell cache from git->${QINIU_LOCAL_CACHE_GIT_REPOSITORY}"
git clone https://$PERSONAL_TOKEN@github.com/${QINIU_LOCAL_CACHE_GIT_REPOSITORY}.git $ACTION_QSHELL_HOME
cd $ACTION_QSHELL_HOME
git fetch
git checkout ${QINIU_LOCAL_CACHE_GIT_REPOSITORY_BRANCH}
git pull

##回退到下载QSHELL_DIR_PATH
cd ${QSHELL_DIR_PATH}
if [ -n "${FORCE_REFRESH_QINIU_ACCOUNT}" ]; then
    echo 'Start run qshell account for use new ak sk'
    ./qshell account ${QINIU_AK} ${QINIU_SK} ${QINIU_USER_NAME}
fi


echo 'Start run qshell upload2'
##增量更新上传(外加多线程)
./qshell qupload2 --overwrite --src-dir=${HEXO_PUBLICL_DIR}/ --bucket=${QINIU_BUCKET} --rescan-local --thread-count 16 --file-list ${NEED_REWRITE_QINIU_FILE}
echo 'done  upload qiniu'
echo 'qiniu upload2 cache to git'
##假如不报错 就把当前的变化直接传送到git上
cd $ACTION_QSHELL_HOME
echo `date` > date.txt
git add .
git commit -m 'transfer local upload2 cache to git'

git push
echo 'qiniu upload2 cache to git done!'






