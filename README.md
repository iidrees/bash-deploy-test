# TEST DEPLOYMENT

#### THIS IS A TEST DEPLOYMENT OF MY CHECKPOINT PROJECT ON AWS USING BASH SCRIPT

##### To test the deployment script, please add the environment variables in the deploy-1.sh file so the application can successfully start.

##### To add the correct env variables look for this function on lines 36 - 53 :

```
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
```

##### NOTE: only the values in the EOF token should be changed for example SECRET=< JWT SECRET > should be SECRET=herokubuild

#### Ensure to change the values on the left side of the variable to the correct value.

#### save the file and then run the command

```
1. sudo bash deploy.sh
2. sudo chmod +x deploy.sh && ./deploy.sh
```
