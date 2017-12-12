#!/usr/bin/env bash

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/alternative/kubernetes-dashboard.yaml
kubectl create -f dashboard-admin.yaml

echo "kubectl -n kube-system edit service kubernetes-dashboard #Change type: ClusterIP to type: NodePort"