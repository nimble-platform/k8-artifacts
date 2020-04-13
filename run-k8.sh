#!/bin/bash

# run infrastructure
if [[ "$1" = "infra" ]]; then

    # create keycloack secret
	kubectl create secret generic keycloak-secrets --from-file=infra/keycloak/keycloak_secrets 

    # spin up the infra services
    # not like in docker setup this will create all the infra services.
    for file in  $(find infra -name '*.yaml'); do kubectl apply -f $file; done

elif [[ "$1" = "database" ]]; then

    # create db
    kubectl apply -f infra/postgres/

elif [[ "$1" = "keycloak" ]]; then

    # create keycloack secret
	kubectl create secret generic keycloak-secrets --from-file=infra/keycloak/keycloak_secrets 

     # create keycloack ingress
	kubectl apply -f  kubeadm/keycloack-ingress.yaml

    # spin up the keycloak instance
    kubectl apply -f infra/keycloack/

elif [[ "$1" = "solr" ]]; then

    # create solr ingress
	kubectl apply -f  kubeadm/solr-ingress.yaml

    # spin up the solr instance
    kubectl apply -f infra/solr/

elif [[ "$1" = "services" ]]; then

    # create services ingress
	kubectl apply -f  kubeadm/services-ingress.yaml

    # apply the global configs
    kubectl apply -f services/global-config.yaml

    # run all services
    for file in  $(find services -name '*.yaml'); do kubectl apply -f $file; done

elif [[ "$1" = "restart-single" ]]; then

	# restart service

    # delete pod 
	kubectl delete -f  services/$2

    # create services ingress
	kubectl apply -f  services/$2

elif [[ "$1" = "services-logs" ]]; then

    # have to provide the pod name to view the logs
	kubectl logs $2 -f
	
else
    echo "Invalid usage"
    exit 2
fi