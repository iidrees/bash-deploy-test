#!/usr/bin/env bash
# File: deploy.sh


function updateUbuntu {
  echo "<<<<<<<<<<<<<<<<<<<<< RUN UBUNTU UPDATE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo apt-get install update
}
function installNodejs {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL NVM & NODEJS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

  echo "<<<<<<<<<<<<<<<<<<<<<<<<<< DOWNLOAD & INSTALL NVM >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  source ~/.bashrc
  echo " <<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL NODEJS WITH NVM >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  nvm install v8.2.1
  echo ""  
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NODE INSTALLATION COMPLETED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}


function cloneApp {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< CLONE REPOSITORY TO BE DEPLOYED >>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo ""
  sudo git clone https://github.com/iidrees/Events-Manager.git
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< CHECKOUT INTO EVENTS-MANAGER DIRECTORY >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo ""
  cd Events-Manager
  ls -a
  echo ""
}

function setupAppEnv {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<< CREATE .env FILE AND POPULATE SAME >>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  touch .env
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<<< REQUEST FOR THE VALUES THAT SHOULD BE IN THE .env FILE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo ""
  printf "Please enter the environment variables in the this formal SECRET=< JWT SECRET >(SECRET=1223445320):"
  read envValue
  done=DONE

  while [ $envValue != $done ]
  do
    if [[ $envValue  =~ [a-zA-Z] ]] 
    then
      echo "This is an env variable"
      echo "$envValue" >> .env
      echo ""
      printf "Please enter DONE when you are done else enter the next value:"
      read envValue
      
    else
      echo "this is not an env variable"
      echo ""
      printf "Please enter DONE when you are done else enter the next value:"
      read envValue
    fi
    cat .env
    echo ""
    echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ENV VARIABLES ADDED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  done

}


function setupPm2 {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL PM2 TO RUN BACKGROUND PROCESSES >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo ""
  sudo npm install -g pm2
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<< PM2 SUCCESSFULLY INSTALLED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}



echo "<<<<<<<<<<<<<<<<<<<<<<<< NGINX >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echo "Please enter a domain name for successful setup of NGINX:"
read domain
echo ""
function setupNginx {
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<< INSTALL NGINX >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo apt-get install nginx
  echo "NGINX VERSION" nginx -v
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SETUP NGINX CONFIGURATION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo rm /etc/nginx/sites-enabled/default
  touch /etc/nginx/sites-available/nginx-router 
  sudo cat > /etc/nginx/sites-available/nginx-router <<_EOF_
  server {
  listen 80;
  server_name $domain;
  location / {
    proxy_set_header  X-Real-IP  $remote_addr;
    proxy_set_header  Host       $http_host;
    proxy_pass        http://127.0.0.1:5050;
  }
}
_EOF_
echo ""
sudo ln -s /etc/nginx/sites-available/nginx-router /etc/nginx/sites-enabled/nginx-router
sudo service nginx restart

echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NGINX CONFIGURATION DONE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}

function startApp {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RUN PM2 TO START APPLICATION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  cd Events-manager/
  sudo npm install 
  NODE_ENV=production npm run seq:db
  sudo pm2 start npm -- start
  echo "<<<<<<<<<<<<<<<<<<<<<<<< APPLICATION STARTED ON THE EC2 INSTANCE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo ""
}

function runSSLSetup {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL > CONFIGURE SSL >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> "
  echo ""
  sudo apt-get update
  sudo apt-get install software-properties-common
  sudo add-apt-repository ppa:certbot/certbot
  sudo apt-get update
  sudo apt-get install python-certbox-nginx
  sudo certbot --nginx -d $domain
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SSL CERTIFICATE CONFIGURATION DONE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}

echo "<<<<<<<<<<<<<<<<<<<<<<<< APPLICATION SUCCESSFULLY DEPLOYED ON AWS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"


updateUbuntu
installNodejs
cloneApp
setupAppEnv 
setupPm2
setupNginx 
startApp
runSSLSetup