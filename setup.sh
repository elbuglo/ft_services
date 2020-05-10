#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    setup.sh                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: lulebugl <lulebugl@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/04/15 10:24:31 by lulebugl          #+#    #+#              #
#    Updated: 2020/04/15 10:49:55 by lulebugl         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# text color
GREEN="\033[0;32m"
BROWN="\033[0;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
RESET="\033[0m"

SSH_USERNAME=lulebugl
SSH_PASSWORD=password

FTPS_USERNAME=admin
FTPS_PASSWORD=admin

## sudo usermod -aG docker $(whoami);

if ! getent group docker | grep "user42" ; then
  sudo adduser $(whoami)
fi

if ! docker ps ; then
  echo error docker not working, did u log off and relogon?
fi

if [[ $(minikube status | grep -c "Running") == 0 ]]
then
	minikube start --vm-driver=docker --extra-config=apiserver.service-node-port-range=1-35000
	minikube addons enable metrics-server
	minikube addons enable ingress
	minikube addons enable dashboard
fi

# if [[ $(minikube status | grep -c "Running") == 0 ]]
# then
# 	minikube start --cpus=2 --memory 4000 --vm-driver=virtualbox --extra-config=apiserver.service-node-port-range=1-35000
# 	minikube addons enable metrics-server
# 	minikube addons enable ingress
# 	minikube addons enable dashboard
# fi

MINIKUBE_IP="$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)"

##### Set the docker images in Minikube #####
eval $(minikube docker-env)

###### Replacing #####

######## NGINX ########
cp	srcs/nginx/srcs/index_model.html		srcs/nginx/srcs/index.html
cp	srcs/nginx/srcs/install_model.sh		srcs/nginx/srcs/install.sh
sed -i s/__SSH_USERNAME__/$SSH_USERNAME/g	srcs/nginx/srcs/install.sh
sed -i s/__SSH_PASSWORD__/$SSH_PASSWORD/g	srcs/nginx/srcs/install.sh
sed -i s/__SSH_USERNAME__/$SSH_USERNAME/g	srcs/nginx/srcs/index.html
sed -i s/__SSH_PASSWORD__/$SSH_PASSWORD/g	srcs/nginx/srcs/index.html
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/nginx/srcs/index.html
sed -i s/__FTPS_USERNAME__/$FTPS_USERNAME/g	srcs/nginx/srcs/index.html
sed -i s/__FTPS_PASSWORD__/$FTPS_PASSWORD/g	srcs/nginx/srcs/index.html

######## TELEGRAF #######
cp	srcs/telegraf/telegraf_model.conf		srcs/telegraf/telegraf.conf
cp	srcs/telegraf_model.yaml				srcs/telegraf.yaml
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/telegraf.yaml
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/telegraf/telegraf.conf
sed -i s/__SSH_USERNAME__/$SSH_USERNAME/g	srcs/nginx/srcs/index.html
sed -i s/__SSH_PASSWORD__/$SSH_PASSWORD/g	srcs/nginx/srcs/index.html

####### FTPS #########
cp	srcs/ftps/install_model.sh				srcs/ftps/install.sh
cp	srcs/ftps/Dockerfile_model				srcs/ftps/Dockerfile
sed -i s/__FTPS_USERNAME__/$FTPS_USERNAME/g	srcs/ftps/install.sh
sed -i s/__FTPS_PASSWORD__/$FTPS_PASSWORD/g	srcs/ftps/install.sh
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/ftps/Dockerfile
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/ftps/install.sh

####### WORDPRESS #######
cp	srcs/wordpress/wp-config_model.php		srcs/wordpress/wp-config.php
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/wordpress/wp-config.php

####### MYSQL ######
cp	srcs/mysql/wp_model.sql					srcs/mysql/wp.sql
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/mysql/wp.sql


SERVICE_LIST="telegraf influxdb grafana nginx mysql phpmyadmin wordpress ftps" #ftps

##### Clean if arg[1] is clean  ####

if [[ $1 = 'clean' ]]
then
	echo -ne $GREEN"➜	Cleaning all services...\n"$RESET
	for SERVICE in $SERVICE_LIST
	do
		kubectl delete -f srcs/$SERVICE.yaml >/dev/null 2>&1
	done
	kubectl delete -f srcs/ingress.yaml >/dev/null 2>&1
	echo -ne $GREEN"✓	Clean complete !\n"$RESET
	exit
fi

echo -ne $BLUE" Update grafana db ... \n"$RESET
echo "UPDATE data_source SET url = 'http://influxdb:8086'" | sqlite3 srcs/grafana/grafana.db

echo -ne $GREEN"Applying yaml:\n"$RESET
kubectl delete -f srcs/ingress.yaml >/dev/null 2>&1
echo -ne $GREEN"		Creating ingress for nginx...\n"$RESET
kubectl apply -f srcs/ingress.yaml
for service in $SERVICE_LIST
do
	echo -ne $GREEN"	--> $service:\n\n"$RESET
	docker build -t "$service"_image srcs/$service >/dev/null 2>&1
	kubectl delete -f srcs/$service.yaml > /dev/null 2>&1
	echo -ne $GREEN"\n		Creating container...\n\n"$RESET
	kubectl apply -f srcs/$service.yaml
	 echo -ne $GREEN"done\n\n"$RESET
done 

###### Display dashboard ######
minikube service list

##### changing password for grafana  #######
kubectl exec -ti $(kubectl get pods | grep grafana | cut -d" " -f1) -- bash -c " cd ./grafana-6.6.0/bin/ ; ./grafana-cli admin reset-admin-password admin" > /dev/null 2>&1

echo -ne $GREEN"launch a command on a pod: \nkubectl exec -it \$(kubectl get pods | grep pod-name | cut -d" " -f1) -- command \n\n"$RESET 
echo -ne $GREEN"killing a pod : \n	kubectl exec -it \$(kubectl get pods | grep mysql | cut -d\" \" -f1) -- /bin/sh -c \"kill 1\"\n"
echo -ne "kubectl exec -it \$(kubectl get pods | grep influxdb | cut -d\" \" -f1) -- /bin/sh -c \"kill 1\"\n"$RESET
echo -ne $GREEN"-> IP : $MINIKUBE_IP \n"$RESET
