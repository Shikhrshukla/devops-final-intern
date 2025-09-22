#!/bin/bash

#Installing Argocd and setting namespaces...
#kubectl create namespace argocd
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep(30)

#Setting default namespace as "argocd"...
#kubectl config set-context --current --namespace=argocd

#Logging...
argocd login --core

#This is your "admin" password for the console
argocd admin initial-password -n argocd

#Destination Clusters
argocd cluster list
