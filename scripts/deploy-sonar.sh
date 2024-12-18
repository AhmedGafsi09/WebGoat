#!/bin/bash

# Create namespace if it doesn't exist
kubectl create namespace devops-tools --dry-run=client -o yaml | kubectl apply -f -

# Apply SonarQube configuration
kubectl apply -f kubernetes/sonarqube/sonarqube-deployment.yaml

# Wait for the pod to be ready
echo "Waiting for SonarQube pod to be ready..."
kubectl wait --for=condition=ready pod -l app=sonarqube -n devops-tools --timeout=300s

# Get NodePort
SONAR_PORT=$(kubectl get svc sonarqube -n devops-tools -o jsonpath='{.spec.ports[0].nodePort}')
echo "SonarQube will be available at: http://20.151.79.23:$SONAR_PORT"
echo "Default credentials: admin/admin"
echo "Please change the password after first login"
echo "Don't forget to update GitHub secrets:"
echo "SONAR_HOST_URL: http://20.151.79.23:$SONAR_PORT"