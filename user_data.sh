#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
sudo docker volume create --driver local --opt type=nfs --opt=o=addr=fs-013b0cb0ec5585cc7.efs.us-east-1.amazonaws.com,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport --opt device=:/ wordpress-content
echo HOST_DB=HOST >> .envdb
echo USER_DB=USER >> .envdb
echo PASSWORD_DB=PASSWORD >> .envdb
echo NAME_DB=DATABASE >> .envdb
curl https://raw.githubusercontent.com/jeancalistro/atv-docker-aws-compass/main/compose.yaml -o compose.yaml
sudo docker-compose --env-file .envdb up -d
