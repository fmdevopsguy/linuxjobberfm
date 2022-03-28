#!/bin/bash

#
# call this script like this: ./build_code_changes.sh build_dir tag_name repo_branch_name
#   where build_dir is the home directory for building
#      and dev2 is image tag name
#

if [ "$4" == "rerun" ]; then
    echo "reruning same branch"
    UP2DATE=$4
else
    UP2DATE=up-to-date
fi

#BIN_BASE=/usr/local/node-v12.18.4-linux-x64/bin
BIN_BASE=''

export NG_CLI_ANALYTICS=false

# get the root directory where building should occur
HOME=$(echo "$(realpath $0)" | cut -d "/" -f2)
echo 'changing to directory ' $HOME ' and building for image tag ' $2

# begin pulling branch
cd /$HOME/www && sudo git checkout -f $3
cd /$HOME/www && RETN=$(sudo git pull)
if grep -q "$UP2DATE" <<< "$RETN"; then
    echo $UP2DATE 'nothing to do, output of git pull is ... ' $RETN
else
    #echo 'changes found. Building ... '
    #cd /$HOME/www && sudo git checkout -f $3
    cd /$HOME/www && sudo git pull origin $3

    # build angular code outside image
    cd /$HOME && cp environment.prod.ts  www/Angular/src/environments/environment.prod.ts
    cd /$HOME && cp environment.prod.ts  www/Workntutor/src/environments/environment.prod.ts
    cd /$HOME/www/Angular && npm install
    cd /$HOME/www/Angular && npm run build
    cd /$HOME/www/Workntutor && npm install &&  npm install @angular/cli@9
    cd /$HOME/www/Workntutor && npm run build-prod

    # build docker image
    #cd /$HOME && sudo docker tag workntutor:$2 workntutor:old_$2
    #cd /$HOME && sudo docker rmi workntutor:$2
    cd /$HOME && sudo docker build -t workntutor:$2 .
    sudo docker tag workntutor:$2 registry.gitlab.com/showpopulous/linuxjobber2/workntutor:$2
    sudo docker push registry.gitlab.com/showpopulous/linuxjobber2/workntutor:$2

    # restart docker service using new image
    #sudo docker service update --image workntutor:$2 --force workntutor$2
fi
