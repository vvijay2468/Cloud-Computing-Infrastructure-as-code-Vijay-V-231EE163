#!/bin/bash
# Installing Docker
sudo apt-get remove docker docker-engine docker.io
sudo apt-get update
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
sudo apt-get update
sudo apt-get install docker-ce -y
sudo usermod -a -G docker $USER
sudo systemctl enable docker
sudo systemctl restart docker

# Creating custom index.html
echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Custom NGINX Page</title>
</head>
<body>
    <h1>VM111111</h1>
    <p>This is a custom webpage served by NGINX.</p>
</body>
</html>' > ~/index.html

# Running NGINX Docker container with custom index.html
sudo docker run --name docker-nginx -p 80:80 -v ~/index.html:/usr/share/nginx/html/index.html nginx:latest
