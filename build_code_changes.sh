#!/bin/bash

#
# call this script like this: ./build_code_changes.sh build_dir tag_name repo_branch_name
#   where build_dir is the home directory for building
#      and dev2 is image tag name
#


# script for building workntutor image for developers

# get the root directory where building should occur
HOME=$(echo "$(realpath $0)" | cut -d "/" -f2)
echo 'changing to directory ' $HOME ' and building for image tag ' $2

# begin pulling branch
cd /$HOME/www && sudo git pull
cd /$HOME/www && sudo git checkout -f $3
cd /$HOME/www && sudo git pull origin $3

# build angular code outside image
cd /$HOME && cp environment.prod.ts  www/Angular/src/environments/environment.prod.ts
cd /$HOME && cp environment.prod.ts  www/Workntutor/src/environments/environment.prod.ts
cd /$HOME/www/Angular && sudo /usr/local/node-v12.18.4-linux-x64/bin/npm install
cd /$HOME/www/Angular && sudo /usr/local/node-v12.18.4-linux-x64/bin/ng build --prod --aot=true
cd /$HOME/www/Workntutor && /usr/local/node-v12.18.4-linux-x64/bin/npm install
cd /$HOME/www/Workntutor && /usr/local/node-v12.18.4-linux-x64/bin/ng build --prod --aot=true

# build docker image
#cd /$HOME && sudo docker tag workntutor:$2 workntutor:old_$2
#cd /$HOME && sudo docker rmi workntutor:$2
cd /$HOME && sudo docker build -t registry.gitlab.com/showpopulous/linuxjobber2/workntutor:$2 .

# restart docker service using new image
sudo docker service update --image registry.gitlab.com/showpopulous/linuxjobber2/workntutor:$2 --force registry.gitlab.com/showpopulous/linuxjobber2/workntutor$2
