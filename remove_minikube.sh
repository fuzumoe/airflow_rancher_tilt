#!/bin/bash

minikube stop
minikube delete --all
rm -rf ~/.minikube
rm -rf ~/.kube
 