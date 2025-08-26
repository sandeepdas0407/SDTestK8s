#!/bin/bash

echo "🚀 Deploying Blog Application to Azure AKS..."

# Configuration
RESOURCE_GROUP="rg-blog-app"
ACR_NAME=""
AKS_NAME="aks-blog-app"
IMAGE_TAG="latest"

# Function to get ACR name
get_acr_name() {
    echo "🔍 Getting ACR name..."
    ACR_NAME=$(az acr list --resource-group $RESOURCE_GROUP --query "[0].name" -o tsv)
    if [ -z "$ACR_NAME" ]; then
        echo "❌ Could not find ACR in resource group $RESOURCE_GROUP"
        exit 1
    fi
    echo "✅ Found ACR: $ACR_NAME"
}

# Function to build and push image
build_and_push_image() {
    echo "🔨 Building and pushing Docker image..."
    
    # Get ACR login server
    ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" -o tsv)
    
    # Login to ACR
    az acr login --name $ACR_NAME
    
    # Build and tag image
    cd ..
    echo "📦 Publishing application..."
    cd WebApplication1
    dotnet publish -c Release -o ../publish --self-contained -r linux-x64
    cd ..
    
    echo "🐳 Building Docker image..."
    docker build -t blog-app:$IMAGE_TAG .
    
    # Tag for ACR
    docker tag blog-app:$IMAGE_TAG $ACR_LOGIN_SERVER/blog-app:$IMAGE_TAG
    
    # Push to ACR
    echo "📤 Pushing image to ACR..."
    docker push $ACR_LOGIN_SERVER/blog-app:$IMAGE_TAG
    
    echo "✅ Image pushed successfully: $ACR_LOGIN_SERVER/blog-app:$IMAGE_TAG"
    
    cd azure-infra
}

# Function to get AKS credentials
get_aks_credentials() {
    echo "🔑 Getting AKS credentials..."
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME --overwrite-existing
    echo "✅ AKS credentials configured"
}

# Function to update Kubernetes manifests
update_k8s_manifests() {
    echo "📝 Updating Kubernetes manifests..."
    ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" -o tsv)
    
    # Update deployment.yaml with ACR image
    sed -i "s|image: blog-app:latest|image: $ACR_LOGIN_SERVER/blog-app:$IMAGE_TAG|g" ../k8s/deployment.yaml
    sed -i "s|imagePullPolicy: IfNotPresent|imagePullPolicy: Always|g" ../k8s/deployment.yaml
    
    # Update all-in-one manifest
    sed -i "s|image: blog-app:latest|image: $ACR_LOGIN_SERVER/blog-app:$IMAGE_TAG|g" ../k8s/k8s-all-in-one.yaml
    
    echo "✅ Kubernetes manifests updated"
}

# Function to deploy to AKS
deploy_to_aks() {
    echo "🚀 Deploying to AKS..."
    
    # Apply manifests
    kubectl apply -f ../k8s/k8s-all-in-one.yaml
    
    # Wait for deployment
    echo "⏳ Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/blog-app-deployment -n blog-app
    
    if [ $? -eq 0 ]; then
        echo "🎉 Deployment successful!"
        
        # Get service information
        echo ""
        echo "📊 Deployment Status:"
        kubectl get pods -n blog-app -o wide
        
        echo ""
        echo "🌐 Service Information:"
        kubectl get services -n blog-app
        
        # Get external IP
        echo ""
        echo "⏳ Waiting for external IP (this may take a few minutes)..."
        kubectl get service blog-app-nodeport -n blog-app -w &
        
        echo ""
        echo "📋 Useful commands:"
        echo "  kubectl get all -n blog-app"
        echo "  kubectl logs -f deployment/blog-app-deployment -n blog-app"
        echo "  kubectl get service blog-app-nodeport -n blog-app"
        
    else
        echo "❌ Deployment failed"
        kubectl get pods -n blog-app
        exit 1
    fi
}

# Main execution
echo "Starting Azure AKS deployment process..."

# Check if Azure CLI is logged in
if ! az account show &> /dev/null; then
    echo "❌ Please login to Azure CLI first: az login"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl."
    exit 1
fi

# Execute deployment steps
get_acr_name
build_and_push_image
get_aks_credentials
update_k8s_manifests
deploy_to_aks

echo "✅ Azure AKS deployment completed!"
