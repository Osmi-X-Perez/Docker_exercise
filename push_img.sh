#!/bin/bash
sudo yum -y update

sudo yum -y install docker

sudo systemctl start docker

sudo systemctl enable docker

sudo cd /home/ec2-user

#---------------HTML--------
sudo cat <<'EOL' > /home/ec2-user/title.html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Soy un HTML Jefaaa</title>
</head>
<body>
    <p>This is DevOps Terraform and Docker HandsOn</p>
</body>
</html>
EOL

#--------------DockerFile-----------------------------

sudo cat <<'EOL' > /home/ec2-user/Dockerfile
FROM nginx
COPY /home/ec2-user/title.html /usr/share/nginx/html/
EOL


sudo docker build -f /home/ec2-user/Dockerfile -t operezx/devops_excercises_osmar .
sudo docker run --name no_me_la_conteiner -d -p 80:80 operezx/devops_excercises_osmar

USERNAME=$(echo operezx)
PASS=$(echo Y0g_Sothoth@)

sudo docker login -u $USERNAME -p $PASS
sudo docker push operezx/devops_excercises_osmar:latest

