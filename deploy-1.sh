#!/usr/bin/env bash
# File: deploy.sh


function updateUbuntu {
  echo "<<<<<<<<<<<<<<<<<<<<< RUN UBUNTU UPDATE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo apt-get install update
  export LC_ALL=C.UTF-8
  export LANG=C.UTF-8
}
function installNodejs {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL NVM & NODEJS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

  echo "<<<<<<<<<<<<<<<<<<<<<<<<<< DOWNLOAD & INSTALL NVM >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  # source ~/.bashrc
  echo " <<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL NODEJS WITH NVM >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  sudo apt-get install -y nodejs
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
  echo "<<<<<<<<<<<<<<<<<<<<<<<<< CREATE .env FILE  >>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  # create a .env file that stores the environment var needed by the application

  sudo bash -c 'cat > .env <<EOF
  SECRET=< JWT SECRET >
  PORT=<APP PORT NO>
  DATABASE_URL=< DATABASE URL >
  CLOUDINARY_URL=< CLOUDINARY URL >
  UPLOAD_PRESET=<CLOUDINARY UPLOAD_PRESET>
  SEED_ADMIN_PW=<ADMIN_TEST PW>
  SEED_SUPERADMIN=<PASSWORD FOR SUPERADMIN>
  SEED_ADMIN=<SEED ADMIN PW>
  SEED_USER=<SEED USER PW>
  EMAIL=<NODE_MAILER EMAIL SETUP>
  PASSWORD=<PW_FOR_EMAIL>
EOF'
}


function setupPm2 {
  # setup background process runner for nodejs so pm2 is installed globally
  echo "<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL PM2 TO RUN BACKGROUND PROCESSES >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo ""
  sudo npm install -g pm2
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<< PM2 SUCCESSFULLY INSTALLED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}



echo "<<<<<<<<<<<<<<<<<<<<<<<< NGINX >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

function setupNginx {
  echo ""
  # Setup nginx by installing the nginx package
  echo "<<<<<<<<<<<<<<<<<<<<<<<< INSTALL NGINX >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo apt-get install nginx -y
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SETUP NGINX CONFIGURATION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  # check if the default or previous config exists and remove same 
  # before creating a fresh nginx config
  sudo rm -rf /etc/nginx/sites-enabled/default
  if [[ -d /etc/nginx/sites-enabled/nginx-router ]]
  then
    sudo rm -rf /etc/nginx/sites-enabled/nginx-router
    sudo rm -rf /etc/nginx/sites-available/nginx-router
  fi
    sudo bash -c 'cat > /etc/nginx/sites-available/nginx-router <<EOF
    server {
    listen 80;
    server_name events-manager.tk www.events-manager.tk;
    location / {
      proxy_pass        http://127.0.0.1:5050;
    }
  }
EOF'
  # when the config file is created a symlink is made here between two dir
  sudo ln -sfn /etc/nginx/sites-available/nginx-router /etc/nginx/sites-enabled/nginx-router
  echo ""
  sudo service nginx restart
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NGINX CONFIGURATION DONE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}

function startApp {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RUN PM2 TO START APPLICATION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  # Install npm modules and dependencies application needs
  sudo npm install --unsafe-perm
  NODE_ENV=production npm run seq:db # Run database migratrion in production
  sudo npm run build # build application 
  sudo pm2 start npm -- start # start application pm2
  echo "<<<<<<<<<<<<<<<<<<<<<<<< APPLICATION STARTED ON THE EC2 INSTANCE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo ""
}

function runSSLSetup {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL > CONFIGURE SSL >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> "
  echo ""
  # install packages for the setup and config of the SSL certificate
  sudo apt-get update
  sudo apt-get install software-properties-common
  sudo add-apt-repository ppa:certbot/certbot
  sudo apt-get update
  sudo apt-get install python-certbot-nginx
  sudo certbot --nginx # begins the configuration of the SSL
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SSL CERTIFICATE CONFIGURATION DONE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}

echo "<<<<<<<<<<<<<<<<<<<<<<<< APPLICATION SUCCESSFULLY DEPLOYED ON AWS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"


# script is run by this main function
function main {
  updateUbuntu
  installNodejs
  cloneApp
  setupAppEnv
  setupPm2
  setupNginx
  startApp
  runSSLSetup
}

main

