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

SSH_USERNAME=nine
SSH_PASSWORD=nine

DB_USER=nine
DB_PASSWORD=nine

FTPS_USERNAME=nine
FTPS_PASSWORD=nine

if [[ $(minikube status | grep -c "Running") == 0 ]]
then
	minikube start --cpus=2 --memory 4000 --vm-driver=virtualbox --extra-config=apiserver.service-node-port-range=1-35000
	minikube addons enable metrics-server
	minikube addons enable ingress
	minikube addons enable dashboard
fi

MINIKUBE_IP=$(minikube ip)

# Set the docker images in Minikube
eval $(minikube docker-env)

# cp srcs/telegraf.conf srcs/ftps/srcs/
# cp srcs/telegraf.conf srcs/grafana/srcs/
# cp srcs/telegraf.conf srcs/influxdb/srcs/
# cp srcs/telegraf.conf srcs/nginx/srcs/

# Replacing

sed -i s/admin/$SSH_USERNAME/g				srcs/nginx/srcs/install.sh
sed -i s/admin/$SSH_PASSWORD/g				srcs/nginx/srcs/install.sh
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/nginx/srcs/index.html
cp	srcs/telegraf_model.yaml				srcs/telegraf.yaml
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/telegraf.yaml
cp	srcs/telegraf/telegraf_model.conf		srcs/telegraf/telegraf.conf
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/telegraf/telegraf.conf
sed -i s/__SSH_USERNAME__/$SSH_USERNAME/g	srcs/nginx/srcs/index.html
sed -i s/__SSH_PASSWORD__/$SSH_PASSWORD/g	srcs/nginx/srcs/index.html
sed -i s/FTPS_USERNAME/$FTPS_USERNAME/g		srcs/ftps/srcs/install.sh
sed -i s/FTPS_PASSWORD/$FTPS_PASSWORD/g		srcs/ftps/srcs/install.sh
cp	srcs/ftps/Dockerfile_model				srcs/ftps/Dockerfile
sed -i s/__MINIKUBE_IP__/$MINIKUBE_IP/g		srcs/ftps/Dockerfile
##sed -i '' for mac 

SERVICE_LIST="ftps telegraf influxdb grafana"

# Clean if arg[1] is clean

if [[ $1 = 'clean' ]]
then
	printf "➜	Cleaning all services...\n"
	for SERVICE in $SERVICE_LIST
	do
		kubectl delete -f srcs/$SERVICE.yaml > /dev/null
	done
	kubectl delete -f srcs/ingress.yaml > /dev/null
	printf "✓	Clean complete !\n"
	exit
fi

echo -ne " Update grafana db ... \n"
echo "UPDATE data_source SET url = 'http://influxdb:8086'" | sqlite3 srcs/grafana/grafana.db

printf "Building Docker images...\n"

#docker build -t nginx_image srcs/nginx
docker build -t ftps_image srcs/ftps
docker build -t telegraf_image srcs/telegraf
docker build -t influxdb_image srcs/influxdb
docker build -t grafana_image srcs/grafana


echo "Applying yaml:"
for service in $SERVICE_LIST
do
	echo "	✨ $service:"	
	if [[ $SERVICE_LIST == "nginx" ]]
	then
		kubectl delete -f srcs/ingress.yaml >/dev/null 2>&1
		echo "		Creating ingress for nginx..."
		kubectl apply -f srcs/ingress.yaml
	fi
	kubectl delete -f srcs/$service.yaml > /dev/null 2>&1
	echo "		Creating container..."
	kubectl apply -f srcs/$service.yaml
	while [[ $(kubectl get pods -l app=$service -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]];
	do
		sleep 1;
		echo "..."
	done
	##sed -i s/__$service-POD__/$(kubectl get pods | grep $service | cut -d" " -f1)/g srcs/grafana/srcs/global.json
	echo "done"
done 

# changing password for grafana
kubectl exec -ti $(kubectl get pods | grep grafana | cut -d" " -f1) -- bash -c " cd ./grafana-6.6.0/bin/ ; ./grafana-cli admin reset-admin-password admin"

#kubectl exec -i $(kubectl get pods | grep grafana | cut -d" " -f1) -- /bin/sh -c "cat >> /usr/share/grafana/conf/provisioning/dashboards/global.json" < srcs/grafana/srcs/global.json > /dev/null 2>&1
#echo "Dashboard ok !"

server_ip=`minikube ip`
echo -ne "\033[1;33m+>\033[0;33m IP : $server_ip \n"







# kubectl delete -f srcs/nginx.yaml  >/dev/null 2>&1
# kubectl apply -f srcs/nginx.yaml
# kubectl delete -f srcs/ingress.yaml  >/dev/null 2>&1
# kubectl apply -f srcs/ingress.yaml
# kubectl delete -f srcs/influxdb-pvc.yaml  >/dev/null 2>&1
# kubectl apply -f srcs/influxdb-pvc.yaml
# kubectl delete -f srcs/influxdb.yaml  >/dev/null 2>&1
# kubectl apply -f srcs/influxdb.yaml
